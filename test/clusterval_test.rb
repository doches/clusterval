require 'test_helper'
require 'lib/clusterval'

class ClustervalTest < Test::Unit::TestCase
	include Clusterval

	def setup
		@clean = false
	end
	
	def teardown
		`rm temp.yaml` if File.exists?("temp.yaml")
	end
	
	def test_hash_file
		hash = {:a => [1,2,3], :b => [4,5,6]}
		fout = File.open("temp.yaml","w")
		fout.puts hash.to_yaml
		fout.close

		c = Clustering.new("temp.yaml")

		assert_equal(2, c.size)
		assert_equal(3, c.clusters[0].size)
		assert_equal(hash[:a],c.clusters[1].items)
		assert_equal([4,5,6,1,2,3],c.items)
	end
	
	def test_hash
		hash = {:a => [1,2,3], :b => [4,5,6]}
		c = Clustering.new(hash)
		
		assert_equal(2, c.size)
		assert_equal(3, c.clusters[0].size)
		assert_equal(hash[:a],c.clusters[1].items)
		assert_equal([4,5,6,1,2,3],c.items)
	end
	
	def test_cleanup
		@clean = true
		c = create_temp_cluster("A B C","D E F A")
		assert_equal(3, c.clusters[1].size)
	end
	
	def test_randomize
		c = create_temp_cluster("A B C","D E F")
		r = c.randomize
		assert_equal(c.items.size,r.items.size)
		assert_equal(c.size,r.size)
	end
	
	def test_yaml
		c = create_temp_cluster("A B C","D E F")
		fout = File.open("temp.yaml","w")
		fout.puts c.to_yaml
		fout.close
		
		x = Clustering.new("temp.yaml")
		assert_equal(c.items.size,x.items.size)
		assert_equal(c.size,x.size)	
	end
	
	def test_empty
		a = Cluster.new("foo bar baz")
		b = Cluster.new("a b c","lbl")
		c = Clustering.new
		assert_nothing_raised { c.add a }
		assert_nothing_raised { c.add b }
		
		assert_equal(2,c.size)
		assert_equal(6,c.items.size)
	end
	
	def test_to_s
		a = Cluster.new("foo bar baz")
		assert_equal(":foo bar baz",a.to_s)
		b = Cluster.new("a b c_c","lbl")
		assert_equal("lbl:a b c_c",b.to_s)
		
		c = create_temp_cluster("A:1 2 3","B:4 5 6")
		assert_equal("A:1 2 3\nB:4 5 6",c.to_s)
	end
	
  def test_load
  	# Create a sample input file
  	fout = File.open("test.cluster","w")
  	fout.puts "A: 1 2 3 4 5"
  	fout.puts "B: 1 2 4 5 6 7"
  	fout.puts "C: 7"
  	fout.close
  	
  	data = nil

  	assert_nothing_raised {	data = Clustering.new("test.cluster") }
  	assert_equal(3, data.clusters.size)
  	assert_not_nil(data.clusters[0].label)
  	assert(data.clusters[0].has_label?)
  	assert_equal(7,data.items.size)
  	
  	begin
	 		`rm test.cluster`
	 	rescue
	 		STDERR.puts "Couldn't delete 'test.cluster', boldly carrying on."
	 	end
  end
  
  def test_precision
  	a = Cluster.new("foo bar baz")
  	b = Cluster.new("foo bar")
  	
  	assert_equal((2.0/3), Clustering.precision(a,b))
  end

  def test_recall
  	a = Cluster.new("foo bar baz")
  	b = Cluster.new("foo bar")
  	
  	assert_equal(1.0, Clustering.recall(a,b))
  end
  
  def test_f
  	a = Cluster.new("foo bar baz")
  	b = Cluster.new("foo bar")
  	
  	assert_equal(0.8, Clustering.f(a,b))
  end
  
  def test_F
  	a = create_temp_cluster("1 2 3","4 5 6")
  	b = create_temp_cluster("1 2","3 5 6","4")
  	
  	assert_equal(2,a.size)
  	assert_equal(3,b.size)

  	assert_equal(Clustering.F_score(a,b),b.F_score(a))
  	assert_equal(4.0/5,Clustering.F_single(a.clusters[0],b))
  	assert_equal(2.0/3,Clustering.F_single(a.clusters[1],b))
  	assert_in_delta(11.0/15, Clustering.F_score(a,b),0.0001)
  end
  
  def test_identity_fscore
  	a = create_temp_cluster("1 2 3","4 5","6 7 8 9","10 11 12 13")
  	assert_equal(1.0, Clustering.F_score(a,a))
  	10.times do 
  		t = a.randomize
  		assert_in_delta(1.0,t.F_score(t),0.000001)
  	end
  end
  
  def test_cluster
  	a = Cluster.new("foo bar baz")
  	assert_equal(3, a.items.size)
  	assert_equal(:foo, a.items[0])
  	assert_nil(a.label)
  	assert(!a.has_label?)
  end
  
  #### Helper functions
  
  def create_temp_cluster(*strings)
  	filename="temp.cluster"
  	fout = File.open(filename,"w")
  	strings.each do |str|
  		if not str.include?(":")
  			str = ":#{str}"
  		end
  		fout.puts "#{str}"
  	end
  	fout.close
  	cluster = Clustering.new(filename,@clean)
  	`rm #{filename}`
  	return cluster
  end
  
end
