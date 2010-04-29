require 'test_helper'
require 'lib/clusterval'

class ClustervalTest < Test::Unit::TestCase
	include Clusterval

	def setup
		
	end
	
	def teardown
	
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
  
  def create_temp_cluster(*strings)
  	filename="temp.cluster"
  	fout = File.open(filename,"w")
  	strings.each { |str| fout.puts ":#{str}" }
  	fout.close
  	cluster = Clustering.new(filename)
  	`rm #{filename}`
  	return cluster
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
  
  def test_cluster
  	a = Cluster.new("foo bar baz")
  	assert_equal(3, a.items.size)
  	assert_equal(:foo, a.items[0])
  	assert_nil(a.label)
  	assert(!a.has_label?)
  end
end
