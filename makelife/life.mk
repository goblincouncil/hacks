# makelife: Conway's Game of Life in GNU Make.
# Usage: make -s -f life.mk BOARD=boards/glider.txt GENS=4
# The whole simulation runs while make reads this file. No recipe runs and
# no shell is started: cells are variables, counting neighbours is $(words).

BOARD ?= boards/glider.txt
GENS ?= 4
MAKEFLAGS += -r
.SUFFIXES:

define nl


endef
empty :=
space := $(empty) $(empty)

# seq,N -> 1 2 ... N, counted by appending one word at a time
seq = $(if $(filter 0,$1),,$(call seq_,$1,1))
seq_ = $(if $(word $1,$2),$2,$(call seq_,$1,$2 $(words x $2)))

# one word per cell: "#..#" -> "# . . #"
chars = $(strip $(subst .,. ,$(subst #,# ,$1)))

raw := $(file <$(BOARD))
rows := $(subst $(nl),$(space),$(raw))
H := $(words $(rows))
$(if $(rows),,$(error makelife: board $(BOARD) is empty or missing))
W := $(words $(call chars,$(firstword $(rows))))
$(foreach r,$(rows),$(if $(filter-out . #,$(call chars,$r)),\
  $(error makelife: bad character in row $r, use . and # only)))
$(foreach r,$(rows),$(if $(filter $W,$(words $(call chars,$r))),,\
  $(error makelife: ragged board, row $r is not $W cells wide)))
nodigits_ = $(subst 0,,$(subst 1,,$(subst 2,,$(subst 3,,$(subst 4,,$(subst 5,,$(subst 6,,$(subst 7,,$(subst 8,,$(subst 9,,$1))))))))))
$(if $(strip $(GENS)),,$(error makelife: GENS must be a whole number))
$(if $(strip $(call nodigits_,$(strip $(GENS)))),$(error makelife: GENS must be a whole number))

XS := $(call seq,$W)
YS := $(call seq,$H)
# the board is a torus: neighbour lookups are a word index into a rotated list
XN := $(wordlist 2,$W,$(XS)) 1
XP := $(lastword $(XS)) $(wordlist 1,$(words $(wordlist 2,$W,$(XS))),$(XS))
YN := $(wordlist 2,$H,$(YS)) 1
YP := $(lastword $(YS)) $(wordlist 1,$(words $(wordlist 2,$H,$(YS))),$(YS))

# load: live cell = variable holding "o", dead cell = empty variable
$(foreach y,$(YS),$(foreach x,$(XS),\
  $(eval c.$x.$y := $(if $(filter #,$(word $x,$(call chars,$(word $y,$(rows))))),o))))

# the 3x3 block around ($x,$y); dead cells are empty and vanish, so $(words) counts the living
nbrs = $(foreach a,$(word $x,$(XP)) $x $(word $x,$(XN)),\
         $(foreach b,$(word $y,$(YP)) $y $(word $y,$(YN)),$(c.$a.$b)))
# the 3x3 block includes the cell itself, so a live cell with 2 or 3
# neighbours counts 3 or 4, and a dead cell with 3 neighbours counts 3
rule = $(if $(c.$x.$y),$(if $(filter 3 4,$(words $(nbrs))),o),$(if $(filter 3,$(words $(nbrs))),o))

step = $(foreach y,$(YS),$(foreach x,$(XS),$(eval n.$x.$y := $(rule))))\
       $(foreach y,$(YS),$(foreach x,$(XS),$(eval c.$x.$y := $(n.$x.$y))))

row = $(subst $(space),,$(foreach x,$(XS),$(if $(c.$x.$y),#,.)))
pop = $(words $(foreach y,$(YS),$(foreach x,$(XS),$(c.$x.$y))))
show = $(info generation $1, population $(pop))$(foreach y,$(YS),$(info $(row)))$(info )

$(call show,0)
$(foreach g,$(call seq,$(GENS)),$(step)$(call show,$g))

.PHONY: all
all: ;
