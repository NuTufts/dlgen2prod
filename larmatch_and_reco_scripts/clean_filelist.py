import os,sys

finput = open('filelists/filelist_mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge.txt','r')
fbook  = open('bookkeeping/fileinfo_mcc9_v29e_dl_run3b_bnb_intrinsic_nue_overlay_nocrtremerge.txt','r')

finput_lines = finput.readlines()
fbook_lines = fbook.readlines()

goodlist = []
bookdict = {}

for l in fbook_lines:
    l = l.strip()
    lineno = int(l.split()[0])
    fname = l.split()[-1]
    subrun1 = int(l.split()[1])
    subrun2 = int(l.split()[2])
    if not (subrun1==0 and subrun2==0):
        bookdict[lineno] = fname

lineno = 0
for l in finput_lines:
    l = l.strip()
    fname = os.path.basename(l)
    if lineno in bookdict:
        if bookdict[lineno] == fname:
            print("good file[",lineno,"]: ",fname)
            goodlist.append( l )    
    lineno += 1

fout = open('cleanlist.txt','w')
for l in goodlist:
    print(l,file=fout)
fout.close()
