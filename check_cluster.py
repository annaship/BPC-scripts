#! /bioware/python-2.7.9-20150330161321/bin/python
# Every 2 minutes checks if cluster is done by username or job name
import time
import os, sys
import subprocess
import getpass

class ClusterUtils:
    def __init__(self):
        pass

    def check_if_array_job_is_done(self, job_name):
        cluster_done = False
        check_qstat_cmd_line = "qstat -r | grep %s | wc -l" % job_name
        print "check_qstat_cmd_line = %s" % check_qstat_cmd_line        
        try:
            p = subprocess.Popen(check_qstat_cmd_line, stdout=subprocess.PIPE, shell=True)
            (output, err) = p.communicate()
            num_proc = int(output)
            print "qstat is running %s '%s' processes" % (num_proc, job_name)
    #         pprint(p)
          
            if (num_proc == 0):
                cluster_done = True
    #         print "cluster_done from check_if_cluster_is_done = %s" % cluster_done
        except:
            print "%s can be done only on a cluster." % job_name
            raise        
        return cluster_done

    def run_until_done_on_cluster(self, job_name):
        start = time.time()  
        time_before = self.get_time_now()
        print "time_before = %s" % time_before
        print "Waiting for the cluster..."
        while True:
            if self.is_local():
                time.sleep(1)        
            else:
                time.sleep(120)        
            cluster_done = self.check_if_array_job_is_done(job_name)
            print "cluster_done = %s" % cluster_done
            if (cluster_done):
                break
      
        elapsed = self.timer(start, time.time())
        print "Cluster is done with %s process in: %s" % (job_name, elapsed)             
        
    def get_time_now(self):
        """date and hour only!"""
        return time.strftime("%m/%d/%Y %H:%M", time.localtime())
  # '2009-01-05 22'

    def print_both(self, message):
        print message
        logger.debug(message)

    def is_local(self):
        print os.uname()[1]
        dev_comps = ['ashipunova.mbl.edu', "as-macbook.home", "as-macbook.local", "Ashipunova.local", "Annas-MacBook-new.local", "Annas-MacBook.local"]
        if os.uname()[1] in dev_comps:
            return True
        else:
            return False
            
    def timer(self, start, end):
        hours, rem = divmod(end - start, 3600)
        minutes, seconds = divmod(rem, 60)
        return "{:0>2}:{:0>2}:{:05.2f}".format(int(hours), int(minutes), seconds)
        

    

if __name__=='__main__':
    myutil = ClusterUtils()
    job_name = getpass.getuser()
    if len(sys.argv) == 2:
    	job_name = sys.argv[1]
    myutil.run_until_done_on_cluster(job_name)

