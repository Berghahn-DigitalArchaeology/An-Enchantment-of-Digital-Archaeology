Please Note: In NetLogo, any line that begins with a semicolon (;) is a comment.

;; Written in NetLogo 6.0.4
;; We implement Tom Brughmans’s (2013) simple pot trade model on
;; top of a network created by the code snippet ‘network import
;; example’
;; Here we have also implemented a ‘breakage’ feature that uses
;; the ‘strength’ value of the network as an indication of the
;; diffi culty of trading pots over a particular route. You might
;; interpret that value as bumpiness of the road, or likelihood
;; of cargoes being lost, etc.

;;---- Things to do in the interface window ——
;; in the interface, create a slider with minimum 0, maximum 1
;; and set its value to 0.5. Call it trade-threshold
;; in the interface, create a slider with minimum 1, maximum 100
;; and set its value at 50. Call it num-pots

;; you can create a ‘kill’ button by right-clicking in the
;; interface, selecting button, and putting the code below
;; into its code panel (without the ;; of course):

;; ask one-of links [die]

;; you can add links to the network randomly by making a button
;; with the following code (without the ;; of course):

;; ask one-of turtles [ create-link-to one-of other turtles
;;                     [set strength random-fl oat 3
;;                     set label strength]]

;;— Things to notice —
;; when you run the code, notice how the default network seems to
;; shunt pots to particular nodes; notice how adding links
;; rejigs the way the ‘economy’ of this model works

turtles-own [node-id pots]

links-own [strength]

globals [links-list breakage-factor] ;; we add the global
;; variable ‘breakage-factor’ to enable links and nodes to
;; communicate data

to go
 let total-pots sum [pots] of turtles
 repeat total-pots
  [ trade-pots
  ]

 let poorturtles turtles with [ pots < 0 ]
 if any? poorturtles
 [
 ask poorturtles [set pots 1]
 ]
;; this prevents division errors,
;; but could also represent a kind of cyclical production

  ask turtles [set size 0.1 + 5 * sqrt (pots / total-pots)]
 tick
end

to trade-pots

let target one-of turtles with [pots > 0 and count out-link-neighbors
> 0]

  if target != nobody and random-float 1 > trade-threshold

;; target represents one site, one turtle at a time that we want
;; to run our trade routine
  [
;; converts the strength of the link to a number the turtles can
;; use
   ask links [set breakage-factor strength]
   ask target
    [
     print breakage-factor
     let pots-loss 1 + breakage-factor
     set pots max (list 0 (pots - pots-loss))

;; 1 pot plus the breakage - so we’re treating the strength of
;; the link as a kind of friction, a certain kind of wastage on
;; that route

  ask one-of out-link-neighbors
   [set pots pots + 1]
;; no breakage, only the pot arrives
   ]
  ]
end

to import-network
 clear-all
 set-default-shape turtles “circle”
 import-attributes
 layout-circle (sort turtles) (max-pxcor - 1)
 import-links
 reset-ticks

;; New code that we are adding to the import network procedure
 ask turtles [
  set pots random (num-pots)
 ]

end

;; This next procedure reads in a files that contains node-
;; specific
;; attributes
;; including an unique identification number

to import-attributes

 ;; This opens the file, so we can use it.
 file-open “attributes.txt”

 ;; Read in all the data in the file
 ;; data on the line is in this order:
 ;; node-id attribute1 attribute2
 while [not file-at-end?]
 [
  ;; this reads a single line into a three-item list
  let items read-from-string (word “[“ file-read-line “]”)
  create-turtles 1 [
   set node-id item 0 items
   set size item 1 items
   set color item 2 items
  ]
 ]
 file-close
end

;; This next procedure reads in a file that contains all the
;; links. The file is simply 3 columns separated by spaces. In
;; this example, the links are directed. The first column
;; contains the node-id of the node originating the link. The
;; second column the node-id of the node on the other end of the
;; link. The third column is the strength of the link.

to import-links
 ;; This opens the file, so we can use it.
 file-open “links.txt”

;; Read in all the data in the file
 while [not file-at-end?]
 [
  ;; this reads a single line into a three-item list
  let items read-from-string (word “[“ file-read-line “]”)
  ask get-node (item 0 items)
  [
   create-link-to get-node (item 1 items)
    [ set label item 2 items
     set strength item 2 items] ; MAR24 added this
  ]
 ]
 file-close
end

;; Helper procedure for looking up a node by node-id.
to-report get-node [id]
 report one-of turtles with [node-id = id]
end
