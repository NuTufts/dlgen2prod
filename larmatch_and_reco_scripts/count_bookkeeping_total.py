import os,sys

bookkeeping_file ="fileinfo_mcc9_v29e_dl_run3_G1_extbnb_dlana.txt"

f = open("bookkeeping/"+bookkeeping_file, 'r' )

tot = 0
ll = f.readlines()

for l in ll:
    l = l.strip()
    file_total = int(l.split()[1])
    tot += file_total

print("Summed total number of events for files in book-keeping file: ",bookkeeping_file)
print("Total entries: ",tot)
