# dlgen2prod

Production Scripts and Book Keeping for DL-Gen 2


# VERSION 0.1

Workflow steps

* LArMatch
* Mask-RCNN
* LArFlow Reco

SparseSSNet 5-class is assumed to be available. So is the WireCell cosmic mask.

## RUN 3 Files

Input Data sets. File lists stored in `run3inputlists`.

Need to make lists for mask-rcnn and larmatch consistent.

| Sample Type       | Num files | Official File List(s) |
| -----------       | --------- | ----------- |
| BNB Nu            |   x | x                   |
| BNB intrinsics    | x | x |
| BNB LowE          | 580 | mcc9_v29e_dl_run3b_bnb_intrinsic_nue_LowE_forlarmatch.list  |
| EXTBNB            | x | x |
| RUN 1 5e19 (oops) | x | x |

LArMatch Lists. How do we know how to align files? In folder, `larmatchlists`.

| Sample Type    | Num files | Official File List(s) |
| -----------    | --------- | ----------- |
| BNB Nu         |   x                   |
| BNB intrinsics | x | x |
| BNB LowE       | 580 | larmatch_v0_mcc9_v29e_dl_run3b_intrinsic_nue_LowE.list |
| EXTBNB         | x | x |
| RUN 1 5e19     | x | x |

Mask-RCNN files

| Sample Type | Num Files | Official File List(s) |
| ----------- | --------- | ----------- |
| BNB Nu      |   x       | x            |
| BNB intrinsics | x | x |
| BNB LowE | x | x |
| EXTBNB | x | x |
| RUN 1 5e19 | x | x |

LArFlow Reco Lists. How do we know how to align files? In folder, `lfrecolists`.

| Sample Type    | Num files | Official File List(s) |
| -----------    | --------- | ----------- |
| BNB Nu         |   x       | x           |
| BNB intrinsics | x | x |
| BNB LowE       | 580 | larmatch_v0_mcc9_v29e_dl_run3b_intrinsic_nue_LowE.list |
| EXTBNB         | x | x |
| RUN 1 5e19     | x | x |



