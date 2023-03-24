convert                                                  \
  -delay 40 -loop 1  -scale 1280x720 -coalesce -layers optimize      \
   $(for i in $(seq 0 40); do echo MFBO_PCA_dynamics_${i}.png; done) \
   MFBO_PCA_dynamics.gif


