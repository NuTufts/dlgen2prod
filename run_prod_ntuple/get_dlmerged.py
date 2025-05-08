import os,sys

def parse_goodlist( goodlist ):
    good_reco_file_dict = {}
    with open(goodlist,'r') as f:
        ll = f.readlines()
        for l in ll:
            l = l.strip()
            try:
                info = l.split()
                fileid = int(info[0])
                reco_ana_file = info[1]
                good_reco_file_dict[fileid] = reco_ana_file
            except:
                pass
    return good_reco_file_dict

def parse_inputlist( inputlist ):
    inputlist_dict = {}
    with open(inputlist,'r') as f:
        ll = f.readlines()
        fid = 0
        for l in ll:
            l = l.strip()
            inputlist_dict[fid] = l
            fid += 1
    return inputlist_dict


if __name__=="__main__":
    
    import argparse
    parser = argparse.ArgumentParser("Get the dlmerged and kpsreco-ana file given a fileid")
    parser.add_argument("fileid",type=int,help="file id")
    parser.add_argument("samplename",type=str,help="Sample name")
    parser.add_argument("reco_version",type=str,help="Reco version")
    parser.add_argument("dlgen2prod_folder",type=str,help="Folder of dlgen2prod repo")
    args = parser.parse_args()

    lm_and_reco_folder = args.dlgen2prod_folder+"/larmatch_and_reco_scripts/"
    
    sys.path.insert(0,lm_and_reco_folder)
    from sample_definitions import get_standard_goodlist_name, get_inputfile_list
    
    goodlist = get_standard_goodlist_name( args.samplename, args.reco_version )
    goodlist_path = lm_and_reco_folder+"/goodoutput_lists/"+goodlist
    if not os.path.exists(goodlist_path):
        print(f"none[badpath:{goodlist_path}]")
        sys.exit(0)
    
    fileid_dict = parse_goodlist( goodlist_path )
    if args.fileid in fileid_dict:
        recoanafile = fileid_dict[args.fileid]
    else:
        print(f"none[nogoodlist_fileid:{args.fileid}]")
        sys.exit(0)

    inputlist = get_inputfile_list( args.samplename, lm_and_reco_folder )
    inputlist_path = lm_and_reco_folder+"/"+inputlist
    inputlist_dict = parse_inputlist( inputlist_path )
    if args.fileid in inputlist_dict:
        dlmergedfile = inputlist_dict[args.fileid]
    else:
        print("none[noinputlist]")
        sys.exit(0)

    print(f"{recoanafile} {dlmergedfile}")
    






