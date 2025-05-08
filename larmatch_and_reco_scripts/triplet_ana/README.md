This script in this folder was used to analyze the log files for larmatch+reco job.

It parses the larmatch standard out and the reco standard out (loglevel-3).
We used this to study how the number of spacepoint proposals from one-plane or in total related to the elasped time and if there was a failure related to this event.

We used this to set limits where processing of the event would stop.
This avoids wasting a large amount of time on events that will likely be thrown out anyway.

To do:

[put run 1 EXT-BNB analysis results here]

From EXT-BNB study, we set the limit to be 5 million proposals on each plane and in total.
This should keep the proposal part of the larmatch stage to under 1-2 minutes and avoid the occasional event taking 5+ minutes to even make proposals.
This cut removes 0.4% of events, which should be safe enough.
But we should confirm with bnb nu and instrinsic events.

[do bnbnu and intrinsic nue study and put plots here.]