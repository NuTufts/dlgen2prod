import os,sys,re
import numpy as np
import ROOT as rt
import sample_definitions as sampledefs


def make_bookkeep_file( input_filelist, bookkeeping_info_file ):
  print("<<<<<<<<< Make Booking file >>>>>>>>>>>>",flush=True)
  NUM_OK = 0
  f = open(input_filelist,'r')
  ll = f.readlines()
  bookout = open(bookkeeping_info_file,'w')
  for n,l in enumerate(ll):
    l = l.strip()
    lb = os.path.basename(l)
    # open root file, get number of entries, run/subrun/event list
    r = rt.TFile( l, 'open' )
    imagetree = r.Get("image2d_wire_tree")
    idtree = r.Get("larlite_id_tree")    
    try:    
      nentries = imagetree.GetEntries()
    except:
      print("ERROR w/ imagetree: ",l,flush=True)
      print("---------------------------------------")
      print(n," ",0," ",0," ",0," ",0,"",0," ",0," ",0," ",lb,file=bookout)
      continue
    #print(l,": ",nentries)
    runid    = np.zeros(nentries,dtype=np.int64)
    subrunid = np.zeros(nentries,dtype=np.int64)
    eventid  = np.zeros(nentries,dtype=np.int64)
    isok = True
    for i in range(nentries):
      try:
        idtree.GetEntry(i)
      except:
        isok = False
        print("ERROR w/ larlite_id_tree: ",l,flush=True)
        print("---------------------------------------")              
        break
      #print(" [",i,"] (",(idtree._run_id,idtree._subrun_id,idtree._event_id))
      runid[i] = idtree._run_id
      subrunid[i] = idtree._subrun_id
      eventid[i] = idtree._event_id
    if isok and imagetree.GetEntries()!=idtree.GetEntries():
      isok = False
      print("ERROR w/ unequal entries in larlite and image tree: ",l,flush=True)
      print("---------------------------------------")
    r.Close()
      
    if isok:
      print(n," ",nentries," ",runid.min()," ",runid.max()," ",subrunid.min(),"",subrunid.max()," ",eventid.min()," ",eventid.max()," ",lb,file=bookout)
    else:
      print(n," ",0," ",0," ",0," ",0,"",0," ",0," ",0," ",lb,file=bookout)
    if n>0 and n%100==0:
      print("processed line ",n,flush=True)
  bookout.close()

  return

def parse_bookkeeping_file( samplename, set_is_good_default=True ):

  bookkeeping_info_file = sampledefs.get_bookkeeping_file( samplename )
  merged_dlreco_prefix = sampledefs.get_merged_dlreco_prefix( samplename )
  
  fbook = open(bookkeeping_info_file,'r')
  ll = fbook.readlines()
  fileinfo = {}
  fileid_list = []
  for l in ll:
    l = l.strip().split()
    fileid = int(l[0])
    fname = l[-1]
    nentries = int(l[1])
    fhash = fname.split(f'{merged_dlreco_prefix}_')[-1].split(".root")[0]
    isgood = set_is_good_default
    if nentries==0:
      isgood = False
    fileinfo[fhash] = {"fileid":fileid,"name":fname,"nentries":nentries,"hash":fhash,"isgood":isgood}
  return fileinfo
  

if __name__=="__main__":
  import argparse
  parser = argparse.ArgumentParser("make_booking_file: Use inputfile list to make the book-keeping file which we will use to track which jobs and map (run,subrun,event) to input files")
  parser.add_argument("samplename",type=str,help="Name of sample. See sample_definitions.py")
  parser.add_argument("--remake",default=False,action='store_true',help="If given, will over-write existing bookfile")
  args = parser.parse_args()

  bookfile = sampledefs.get_bookkeeping_file( args.samplename, do_not_check_exists=True )
  if os.path.exists(bookfile) and args.remake==False:
    print("Book-file already exists. Give --remake flag if you want to remake and overwrite")
    sys.exit(0)

  
  input_filelist = sampledefs.get_inputfile_list( args.samplename )
  make_bookkeep_file( input_filelist, bookfile )
