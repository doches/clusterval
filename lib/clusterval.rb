require 'yaml'

module Clusterval

# Represents a clustering over an arbitrary set of items (internally represented as Symbols).
class Clustering
	# Get an array of Clusters contained in this Clustering
	attr_reader :clusters
	# Get an array of items contained in this Clustering
	attr_reader :items
	
	# Load a clustering from +filename+. If the file ends with +.yaml+ or +.yml+, Clusterval will treat it as an
	# existing Clustering which has been saved to disk with Clustering#to_yaml; otherwise, it expects a file of the form:
	#
	#   [optional label] : item1 item2 item3 ...
	#   [optional label] : item2 item_with_spaces item 4
	#   ...
	#
	# Alternatively, if <tt>filename</tt> contains a Hash which has been dumped with to_yaml, load
	# it and create a clustering based on the Hash.
	#
	# If <tt>filename</tt> is itself a Hash (I know, it's weird), create a clustering based on the hash.
	#
	# If <tt>filename</tt> is nil, create an empty clustering of the zero items into zero clusters.
	# 
	# If <tt>clean</tt> is true, do not allow identical items to appear in multiple clusters.
	def initialize(filename=nil,clean=false)
		if filename.nil?
			@clusters = []
			@items = []
		elsif filename.is_a?(Hash)
			load_from_hash(filename)
		elsif filename =~ /ya?ml$/
			temp = YAML.load_file(filename)
			if temp.is_a?(Clustering)
				@clusters = temp.clusters
				@items = temp.items
			elsif temp.is_a?(Hash)
				load_from_hash(temp)
			end
		else # Load from custom file format
			load_from_file(filename,clean)
		end
	end
	
	# Add a cluster to this Clustering
	def add(cluster)
		@clusters.push cluster
		@items = @items | cluster.items
	end
	
	# Returns the number of clusters in this Clustering.
	def size
		@clusters.size
	end
	
	# Create a new clustering with the same items and # of clusters as this one, but
	# in which items have been assigned to clusters randomly
	def randomize(target_size=nil)
		target_size ||= @clusters.size
		new = Clustering.new
		clusters = Array.new(target_size,nil).map { |x| [] }
		@clusters.each_with_index do |cluster,i|
			cluster.items.each do |item|
				index = (rand*clusters.size).to_i
				clusters[index].push item
			end
		end
		while clusters.reject { |x| x.size != 0 }.size > 0
			sorted = clusters.sort { |a,b| a.size <=> b.size }
			sorted[0].push sorted.pop.pop
		end
		clusters.map { |list| Cluster.new(list.map { |x| x.to_sym },nil) }.each { |c| new.add(c) }
		return new
	end
	
	# Calculate the precision of Cluster b w.r.t. Cluster a
	def Clustering.precision(a,b)
		(a.items & b.items).size.to_f / a.items.size
	end
	
	# Calculate the recall of Cluster b w.r.t. Cluster a
	def Clustering.recall(a,b)
		(a.items & b.items).size.to_f / b.items.size
	end
	
	# Calculate the F-value of two clusters
	def Clustering.f(a,b)
		precision = Clustering.precision(a,b)
		recall = Clustering.recall(a,b)
		
		return (2 * precision * recall).to_f / (precision + recall)
	end
	
	# Find the F-Score of a single cluster from the gold clustering.
	def Clustering.F_single(cluster,clustering)
		clustering.clusters.map { |other_cluster| Clustering.f(cluster,other_cluster) }.reject { |x| x.nan? }.sort.pop || 0.0
	end
	
	# Calculate the F-Score between two clusterings
	def Clustering.F_score(gold, candidate)
		# First we need to ensure that the candidate contains all of the items of the gold, adding them
		# to a dummy cluster in candidate if necessary...
		dummy = Cluster.new([],"missing")
		gold.items.each do |gold_item|
			if not candidate.items.include?(gold_item)
				dummy.add(gold_item)
			end
		end
		if dummy.size > 0
			candidate.clusters.push dummy
			candidate.items.push dummy.items
			candidate.items.flatten!
		end
		gold.clusters.inject(0) { |s,cluster| s += (cluster.size.to_f / candidate.items.size) * Clustering.F_single(cluster, candidate) }
	end
	
	# Calculate the F-Score between this clustering and a gold standard clustering
	def F_score(gold)
		Clustering.F_score(gold,self)
	end
	
	# Get a string representation of this Clustering (in the same format as the expected input to Clustering#new
	def to_s
		@clusters.map { |x| x.to_s }.join("\n")
	end
	
	private
	
	# Load from a custom file format
	def load_from_file(filename,clean)
		begin
			@clusters = []
			@items = []
			
			raise IOError.new("#{filename} not found") if not File.exists?(filename)
			
			IO.foreach(filename) do |line|
				label, items = *line.split(":",2).map { |x| x.strip }
				items = items.split(" ").map { |x| (x.respond_to?(:to_sym) and not x.to_sym.nil?) ? x.to_sym : x }
				items = items - @items if clean
				if items.size > 0
					items.reject! { |x| @items.include?(x) }
					cluster = Cluster.new(items,label)
					@items = @items | cluster.items
					@clusters.push cluster
				end
			end
		rescue IOError
			raise $!
		end
	end
	
	def load_from_hash(hash)
		@clusters = []
		@items = []
		
		hash.each_pair do |key,list|
			list.map! { |x| (x.respond_to?(:to_sym) and not x.to_sym.nil?) ? x.to_sym : x }
			list.reject! { |x| @items.include?(x) }
			cluster = Cluster.new(list,key)
			@items = @items | cluster.items
			@clusters.push cluster
		end
	end
end

# A single Cluster containing some number of items with a single optional label
class Cluster
	# List of items contained in this Cluster
	attr_accessor :items
	# Optional label (for reporting)
	attr_accessor :label

	# Create a cluster from an array of items and an optional label. If +items+ is a String it will be parsed into an array of Symbols by splitting on spaces (i.e. +"foo bar baz"+ will become +[:foo, :bar, :baz]+).	
	def initialize(items, label=nil)
		if items.is_a?(String)
			if items.size <= 0
				raise "Cluster#initialize expects an array or a space-delimited String as the first argument; given a String of length zero!"
			end
			items = items.split(" ").map { |x| x.strip.to_sym }
		elsif items.respond_to?(:map)
			items = items.map { |x| x.to_sym.nil? ? x : x.to_sym }
		else
			raise "Cluster#initialize expects an array or a space-delimited String as the first argument; given #{items.class}"
		end
	
		@items = items
		@label = label
	end
	
	# Add an item to this cluster
	def add(item)
		@items.push (item.to_sym.nil? ? item : item.to_sym)
	end
	
	# Returns the number of items in this Cluster
	def size
		@items.size
	end
	
	# Convenience method for checking to see if this Cluster is labeled.
	def has_label?
		not @label.nil?
	end
	
	# Get a string representation of this Cluster. Used by Clustering#to_s.
	def to_s
		"#{@label}:#{@items.map { |x| x.to_s }.join(' ')}"
	end
end

end
