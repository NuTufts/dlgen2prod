import os,sys
import ROOT as rt
import array

BRANCHES = ["ntriples_plane0",
            "ntriples_plane1",
            "ntriples_plane2",
            "elapsed_plane0",
            "elapsed_plane1",
            "elapsed_plane2",
            "deadpixels_plane0",
            "deadpixels_plane1",
            "deadpixels_plane2",
            "total_triplets",
            "triplets_elapsed",
            "isok"]

def get_empty_data():
    data_dict = {}
    for b in BRANCHES:
        data_dict[b] = 0.0
    return data_dict
            

def parse_logfile( logfile, out_root_filename ):
    flog = open(logfile,'r')
    llog = flog.readlines()

    """
Opening a larmatchme block
deploy_larmatchme_v2.py

Opening a Run block
[[ RUN ENTRY 0 ]]

Info to parse
[FlowTriples] for flow source[0] to target[1] planes found 108592 triples ndeadch-added=8382 elasped=10.4978
[FlowTriples] for flow source[0] to target[2] planes found 134529 triples ndeadch-added=3919 elasped=0.162888
[FlowTriples] for flow source[1] to target[0] planes found 108592 triples ndeadch-added=8382 elasped=0.198747
[FlowTriples] for flow source[1] to target[2] planes found 89518 triples ndeadch-added=4157 elasped=0.103207
[FlowTriples] for flow source[2] to target[0] planes found 134529 triples ndeadch-added=3919 elasped=0.160218
[FlowTriples] for flow source[2] to target[1] planes found 89518 triples ndeadch-added=4157 elasped=0.097239
sparse pixel totals before deadch additions: (12383,11821,8055)
sparse pixel totals after deadch additions: (16540,15740,16437)
  deadpixels_to_add[plane=0]: 16540
  deadpixels_to_add[plane=1]: 15740
  deadpixels_to_add[plane=2]: 16437
...
[PrepMatchTriplets] made total of 260567 unique index triplets. time elapsed=13.5021
[PrepMatchTriplets] number removed for not intersecting: 0
[PrepMatchTriplets] num zero triplets: 0
[PrepMatchTriplets::make_triplet_array] withtruth=0
  make numpy array with indices from triplets[0:260567]
  number of triplets proposed: 260567
  number of indices: 260567
  number of entries in output array: 260567

Close of a larmatchme block
run_kpsrecoman.py
    """

    # would like an indicator -- early as possible -- to give up on the event
    in_larmatch_block = False
    in_kpsrecoman_block = False
    current_entry = None
    current_data = None
    current_jobid = -1
    current_entry = -1
    stored_data = {}
    current_recoentry = None
    
    for l in llog:
        l = l.strip()

        if 'JOBID' in l:
            current_jobid = int(l.split()[-1])
            continue

        if not in_larmatch_block:
            # we search for the beginning of the larmatch block
            if "deploy_larmatchme_v2.py" in l:
                in_larmatch_block = True
                current_data = None
                #print("FOUND LARMATCH BLOCK START")
                continue

        if in_larmatch_block:
            # while in a larmatch block
            # look for end of block condition and store data
            if "run_kpsrecoman.py" in l:
                in_larmatch_block = False
                in_kpsrecoman_block = True
                if current_data is not None:
                    stored_data[(current_jobid,current_entry)] = current_data
                current_data = None
                #print("BAD LARMATCH ENTRY END: Next reco job")
                continue
            if "deploy_larmatchme_v2.py" in l:
                in_larmatch_block = True
                if current_data is not None:
                    stored_data[(current_jobid,current_entry)] = current_data                    
                # need to reset event data
                current_data = None
                #print("BAD LARMATCH ENTRY END: Next larmatch job")  
                continue
            if "End of entry[" in l:
                # this is a proper end
                if current_data is not None:                
                    current_data['isok'] = 1.0
                    stored_data[(current_jobid,current_entry)] = current_data
                current_data = None
                #print("GOOD LARMATCH ENTRY END")
                continue

            # collect data for dictionary
            if "ENTRY" in l:
                # start of entry
                #print("LARMATCH ENTRY START!")
                current_entry = int(l.split()[3])
                current_data = get_empty_data()
                continue

            # fill data entries
            if 'for flow source[0] to' in l:
                info = l.split()
                current_data["ntriples_plane0"] += int(info[8])
                current_data["elapsed_plane0"]  += float(info[-1].split("=")[-1])
                continue
            elif 'for flow source[1] to' in l:
                info = l.split()
                current_data["ntriples_plane1"] += int(info[8])
                current_data["elapsed_plane1"]  += float(info[-1].split("=")[-1])
                continue
            elif 'for flow source[2] to' in l:
                info = l.split()
                current_data["ntriples_plane2"] += int(info[8])
                current_data["elapsed_plane2"]  += float(info[-1].split("=")[-1])
                continue
            elif 'deadpixels_to_add[plane=0]' in l:
                info = l.split()
                current_data["deadpixels_plane0"] += int(info[-1])
                continue
            elif 'deadpixels_to_add[plane=1]' in l:
                info = l.split()
                current_data["deadpixels_plane1"] += int(info[-1])
                continue
            elif 'deadpixels_to_add[plane=2]' in l:
                info = l.split()
                current_data["deadpixels_plane2"] += int(info[-1])
                continue
            elif '[PrepMatchTriplets] made total of' in l:
                info = l.split()
                current_data["total_triplets"] = int(info[4])
                current_data["triplets_elapsed"] = float(info[-1].split("=")[-1])
                continue

        if in_kpsrecoman_block:
            # look for end of block
            if in_larmatch_block:
                in_kpsrecoman_block = False
                current_recoentry = None
                continue

            # if in block, look for entry data
            if '[ENTRY ' in l:
                reco_entry = int(l.split()[1])
                current_recoentry = reco_entry
                job_entry = (current_jobid,reco_entry)
                if job_entry in stored_data and stored_data[job_entry]['isok']>0.5:
                    stored_data[job_entry]['isok'] += 1.0
                continue
            if 'Selection variables made:' in l:
                # reached the end of the reco entry
                job_entry = (current_jobid,current_recoentry)
                if job_entry in stored_data and stored_data[job_entry]['isok']>1.5:
                    stored_data[job_entry]['isok'] += 1.0
            
                
    #end of loop
    print("number of stored entry data: ",len(stored_data))

    # write to output root file
    out = rt.TFile(out_root_filename,"recreate")
    tree = rt.TTree("tripletstats","Stats on triplet-based spacepoint proposal")
    branch_vars = {}
    for b in BRANCHES:
        branch_vars[b] = array.array('f',[0.0])
        tree.Branch(b,branch_vars[b],f'{b}/F')
    stored_data_keys = stored_data.keys()
    for k in stored_data_keys:
        data = stored_data[k]
        #print(k,": ",data)
        for b in BRANCHES:
            branch_vars[b][0] = data[b]
        if data['isok']<2.5 and False:
            print("pause for bad example")
            input()
        tree.Fill()

    tree.Write()
    out.Close()


if __name__=="__main__":
    
    #parse_logfile( "larmatchme_larflowreco_mcc9_v29e_dl_run1_C1_extbnb_jobid0106_13510529.log", "test.root" )

    logdir = "../logdir/v3dev_lm_showerkp_retraining/mcc9_v29e_dl_run1_C1_extbnb/"
    pfind = os.popen(f"find {logdir} -name larmatchme_larflowreco_*.log")
    lfind = pfind.readlines()
    nlogs = 0
    ntot = len(lfind)
    print("total number of logs to parse: ",ntot)
    os.system("mkdir outdir")
    for l in lfind:

        if nlogs%100==0:
            print("parseing log ",nlogs," of ",ntot)
        l = l.strip()
        print("parse: ",l)
        lbase = os.path.basename(l)
        outpath = "outdir/"+lbase.replace(".log",".root")
        parse_logfile( l, outpath )
        nlogs += 1


        

        

        
