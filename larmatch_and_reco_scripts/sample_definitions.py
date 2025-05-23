import os,sys

# dictionary to organize info on samples that have been processed
sample_definitions = {
    "mcc9_v28_wctagger_bnb5e19":{"dlmerged":"filelists/filelist_mcc9_v28_wctagger_bnb5e19.txt",
                                 "merged_dlreco_prefix":"merged_dlreco",                                 
                                 "reco_outdir":"/cluster/tufts/wongjiradlabnu/nutufts/data",
                                 "bookkeeping":"bookkeeping/fileinfo_mcc9_v28_wctagger_bnb5e19.txt"},
    "mcc9_v29e_dl_run3_G1_extbnb_dlana":{"dlmerged":"../maskrcnn_input_filelists/mcc9_v29e_dl_run3_G1_extbnb_dlana_MRCNN_INPUTS_LIST.txt",
                                         "merged_dlreco_prefix":"merged_dlreco",                                         
                                         "reco_outdir":"/cluster/tufts/wongjiradlabnu/nutufts/data",
                                         "bookkeeping":"bookkeeping/fileinfo_mcc9_v29e_dl_run3_G1_extbnb_dlana.txt"},
    "mcc9_v40a_dl_run3b_bnb_nu_overlay_500k_CV":{"dlmerged":"filelists/filelist_mcc9_v40a_dl_run3b_bnb_nu_overlay_500k_CV.txt",
                                                 "merged_dlreco_prefix":"merged_dlreco",                                                 
                                                 "reco_outdir":"/cluster/tufts/wongjiradlabnu/nutufts/data/",
                                                 "bookkeeping":"bookkeeping/fileinfo_mcc9_v40a_dl_run3b_bnb_nu_overlay_500k_CV.txt"},
    "mcc9_v40a_dl_run1_bnb_intrinsic_nue_overlay_CV":{"dlmerged":"filelists/filelist_mcc9_v40a_dl_run1_bnb_intrinsic_nue_overlay_CV.txt",
                                                      "merged_dlreco_prefix":"merged_dlreco",                                                      
                                                      "reco_outdir":"/cluster/tufts/wongjiradlabnu/nutufts/data/",
                                                      "bookkeeping":"bookkeeping/fileinfo_mcc9_v40a_dl_run1_bnb_intrinsic_nue_overlay_CV.txt"},
    "mcc9_v29e_dl_run1_C1_extbnb":{"dlmerged":"filelists/filelist_mcc9_v29e_dl_run1_C1_extbnb.txt",
                                   "merged_dlreco_prefix":"merged_dlreco",                                   
                                   "reco_outdir":"/cluster/tufts/wongjiradlabnu/nutufts/data/",
                                   "bookkeeping":"bookkeeping/fileinfo_mcc9_v29e_dl_run1_C1_extbnb.txt"},
    "mcc9_v28_wctagger_bnboverlay":{"dlmerged":"filelists/filelist_mcc9_v28_wctagger_bnboverlay.txt",
                                    "merged_dlreco_prefix":"merged_dlreco",                                    
                                    "reco_outdir":"/cluster/tufts/wongjiradlabnu/nutufts/data/",
                                    "bookkeeping":"bookkeeping/fileinfo_mcc9_v28_wctagger_bnboverlay.txt"},
    "mcc9_v28_wctagger_nueintrinsics":{"dlmerged":"filelists/filelist_mcc9_v28_wctagger_nueintrinsics.txt",
                                       "merged_dlreco_prefix":"merged_dlreco",                                    
                                       "reco_outdir":"/cluster/tufts/wongjiradlabnu/nutufts/data/",
                                       "bookkeeping":"bookkeeping/fileinfo_mcc9_v28_wctagger_nueintrinsics.txt"}
}

def print_sample_names():    
    for name in sample_definitions:
        print(name)

def get_sample_names():
    sample_list = []
    for name in sample_definitions:
        sample_list.append(name)
    return sample_list

def get_sample_info(samplename):
    if samplename in sample_definitions:
        sample_info = sample_definitions[samplename]
        return sample_info
    else:
        raise ValueError("samplename=",samplename," not listed in sample defintions. please update.")
    return None
    
def get_bookkeeping_file(samplename, do_not_check_exists=False):
    if samplename in sample_definitions:
        sample_info = sample_definitions[samplename]
        if "bookkeeping" in sample_info:
            bk_file = sample_info["bookkeeping"]
            if os.path.exists(bk_file) or do_not_check_exists==True:            
                return bk_file
            else:
                raise ValueError("Booking file path for sample=",samplename," not found: ",bk_file)
        else:
            raise ValueError("booking file not listed in the sample definition. please update.")
    else:
        raise ValueError("samplename=",samplename," not listed in sample defintions. please update.")
    
    return None

def get_inputfile_list(samplename,folder="."):
    
    if samplename in sample_definitions:
        sample_info = sample_definitions[samplename]
        if "dlmerged" in sample_info:
            dlmerged_filelist = sample_info["dlmerged"]
            if os.path.exists(folder+"/"+dlmerged_filelist):
                return dlmerged_filelist
            else:
                raise ValueError("dlmerged input file list for sample=",samplename," not found: ",dlmerged_filelist)
        else:
            raise ValueError("dlmerged input file list not in the sample definition. please update.")
    else:
        raise ValueError("samplename=",samplename," not listed in sample defintions. please update.")
    
    return None

def get_reco_output_dir(samplename):
    
    if samplename in sample_definitions:
        sample_info = sample_definitions[samplename]
        if "reco_outdir" in sample_info:
            reco_outdir = sample_info["reco_outdir"]
            if os.path.exists(reco_outdir):
                return reco_outdir
            else:
                raise ValueError("LANTERN reco output directory for sample=",samplename," not found: ",reco_outdir_filelist)
        else:
            raise ValueError("LANTERN reco output directory not in the sample definition. please update.")
    else:
        raise ValueError("samplename=",samplename," not listed in sample defintions. please update.")
    
    return None

def gen_standard_reco_outputdir( samplename, reco_version ):
    """
    This is the standard template for labeling the output directory for the LANTERN reco files.
    """
    toplevel_outdir = get_reco_output_dir(samplename)
    outfolder=toplevel_outdir+"/%s/%s/larflowreco/ana"%(reco_version,samplename)
    return outfolder

def get_merged_dlreco_prefix( samplename ):
    info = get_sample_info(samplename)
    if "merged_dlreco_prefix" in info:
        return info["merged_dlreco_prefix"]
    else:
        raise ValueError("'merged_dlreco_prefix' parameter not in sampleinfo for sample=",samplename)

def get_standard_goodlist_name( samplename, reco_version ):
    goodoutput_filename=f"goodoutput_list_{samplename}_{reco_version}.txt"
    return goodoutput_filename


if __name__=="__main__":
    print("Print sample definnitions defined:")
    for k in sample_definitions:
        print("  ",k)
