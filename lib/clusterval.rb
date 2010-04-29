#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),"..","lib")

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
	def initialize(filename)
		if filename =~ /ya?ml$/
			raise "YAML loading not implemented!"
		else # Load from custom file format
			load_from_file(filename)
		end
	end
	
	# Returns the number of clusters in this Clustering.
	def size
		@clusters.size
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
		clustering.clusters.map { |other_cluster| Clustering.f(cluster,other_cluster) }.reject { |x| x.nan? }.sort.pop
	end
	
	# Calculate the F-Score between two clusterings
	def Clustering.F_score(gold, candidate)
		gold.clusters.inject(0) { |s,cluster| s += (cluster.size.to_f / candidate.items.size) * Clustering.F_single(cluster, candidate) }
	end
	
	# Calculate the F-Score between this clustering and a gold standard clustering
	def F_score(gold)
		Clustering.F_score(gold,self)
	end
	
	private
	
	# Load from a custom file format
	def load_from_file(filename)
		begin
			@clusters = []
			@items = []
			
			IO.foreach(filename) do |line|
				label, items = *line.split(":",2).map { |x| x.strip }
				cluster = Cluster.new(items,label)
				@items = @items | cluster.items
				@clusters.push cluster
			end
		rescue IOError
			raise $!
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
		elsif items.responds_to?(:map)
			items = items.map { |x| x.to_sym }
		else
			raise "Cluster#initialize expects an array or a space-delimited String as the first argument; given #{items.class}"
		end
	
		@items = items
		@label = label
	end
	
	# Returns the number of items in this Cluster
	def size
		@items.size
	end
	
	# Convenience method for checking to see if this Cluster is labeled.
	def has_label?
		not @label.nil?
	end
end

if __FILE__ == $0
	require 'optparse'
	
	options = {}
	hack = nil
	OptionParser.new do |opts|
		opts.banner = "Usage: clusterval [options]"
		
		opts.on("-g","--gold FILENAME","(required) Load gold clustering from FILENAME") do |file|
			options[:gold] = file
		end
		
		opts.on("-c","--candidate FILENAME", "(required) Load candidate clustering from FILENAME") do |file|
			options[:candidate] = file
		end
		
		opts.on_tail("-h","--help","Show this help") do
			puts opts
			exit
		end
		
		hack = opts
	end.parse!
	
	if options[:gold].nil? or options[:candidate].nil?
		puts hack
		exit
	end
	
	gold = Clustering.new(options[:gold])
	candidate = Clustering.new(options[:candidate])
	
	puts candidate.F_score(gold)
end

end
