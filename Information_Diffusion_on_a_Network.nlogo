;; Please Note: In NetLogo, any line that begins with a semicolon (;) is a comment.

;; built for NetLogo version 6.04
;; a version of the itineraries model that
;; loads a network dataset. ’Travel difficulty’ is represented by
;; the ‘strength’ value of the links, puts some agents on it,
;; has them wander around, at differing speeds (or distances)
;; and measures how long it takes for a message to be ‘heard’ by
;; everyone
;;----
;; the model is built by combining default code snippets in
;; NetLogo:
;; network import
;; communication t-t network example
;; link walking turtles
;; Thanks to Andreas Angourakis for looking over the code and
;; suggesting improvements

;; in the interface, you’ll need to create a slider called

;; num-walkers

;; and make sure that the minimum is set to 2 and the ‘value’
;; (starting position of the slider) is at least 2 or more

;; you can also build some monitors. For instance, right-click in
;; the interface and select new monitor, then paste this code
;; into it:
;; ((count walkers with [message?]) / (count walkers)) * 100

;; this will tell you the per cent of the population that has
;; heard the message.
;; you could graph this by making a new plot and giving it the
;; same code

;; right-click, select plot, and in plot update commands paste
;; the same code.

breed [nodes node] ;; these are our sites
nodes-own [node-id]
breed [walkers walker] ;; the turtles who wander around
walkers-own [ ;; variables that only the walkers own
 location
 message?
 new-location
 journey-time]

links-own [strength]

globals [links-list travel-factor] 
;; travel factor has to be
;; accessible by turtles of either breed

to setup
 import-network
 create-walkers num-walkers 
[
  set color red
  set shape "person"
  set size 2
  set location one-of nodes ;; tells our new walker its new home
  move-to location ;; moves the walker there directly
  set message? false ;; ignorance is bliss
  set new-location one-of [link-neighbors] of location 
    ;; gives the walkers a travel goal
  set journey-time 1 ;; initial degree of forward movement: one patch at a time
 ]
 ask one-of walkers [ set message? true ]
 reset-ticks
end

to go
 ;; we ask the walkers:
 ;; go walking,
 ;; talk to anyone else who happens to be present,
 ;; change their color if they’ve encountered someone with the message,
 ;; test to see if they’ve arrived at their new destination
 ;; and then if everyone has the message we stop the simulation.

 ask walkers [
  move
  communicate
  recolor
  check-if-arrived
 ]
 if ((count walkers with [message?]) / (count walkers)) * 100 = 100 [stop]
tick
end

to move
 face new-location ;; make sure they’re heading the correct
;; direction at all times
 ifelse random-float 1 > 0.5 [fd 1][fd journey-time]
;; without the chance of them slowing down to one patch at a
;; time, they sometimes will overshoot the target and get caught
;; overshooting it back and forth.
end

to check-if-arrived
 let arrived one-of nodes-here
;; see if the node they’re at happens to be the one they’re
;; looking at

  if arrived = new-location
   [set location new-location
    choose-destination]
 ;; if it is
 ;; update their ‘location’ variable to where they are now
 ;; and search out a new destination
end

to choose-destination
 set new-location one-of [link-neighbors] of location
 ;; see what places are connected to this one
  ask one-of links with [
   (end1 = [location] of myself and end2 = [new-location] of myself) or
   (end2 = [location] of myself and end1 = [new-location] of myself)]
 ;; adjust the travel-factor (distance, ease of travel) to the
 ;; value of the new path/link
 
 [set travel-factor strength]
 
 ;; adjust speed so that it is modulated by this new value
 set journey-time (1 / travel-factor)
end

to communicate ;; turtle procedure
 if any? other walkers-here with [message?]
 ;; hello? anybody here?
  [ set message? true ]
 ;; if yes, then now I know the message too
end

to recolor ;; walker procedure
 if message?
  [ set color blue ]
end

to import-network
 clear-all
 set-default-shape turtles "circle"
 import-attributes
 layout-circle (sort turtles) (max-pxcor - 1)
 import-links
 reset-ticks

end

;; This procedure reads in a files that contains node-specific
;; attributes
;; including an unique identification number

to import-attributes
 ;; This opens the file, so we can use it.
 file-open "attributes.txt"
 ;; Read in all the data in the file
 ;; data on the line is in this order:
 ;; node-id attribute1 attribute2
 while [not file-at-end?]
 [
  ;; this reads a single line into a three-item list
  let items read-from-string (word "[" file-read-line "]")
  create-nodes 1 [ ;; note the change
   set node-id item 0 items
   set size item 1 items
   set color item 2 items
  ]
 ]
 file-close
end

;; This procedure reads in a file that contains all the links
;; The file is simply 3 columns separated by spaces. In this
;; example, the links are directed. The first column contains
;; the node-id of the node originating the link. The second
;; column the node-id of the node on the other end of the link.
;; The third column is the strength of the link.

to import-links
 ;; This opens the file, so we can use it.
 file-open "links.txt"
 ;; Read in all the data in the file
 while [not file-at-end?]
 [
  ;; this reads a single line into a three-item list
  let items read-from-string (word "[" file-read-line "]")
  ask get-node (item 0 items)
  [
   create-link-with get-node (item 1 items)
;; nb! Create-link-with is undirected, create-link-to is
;; directed!

    [ set label item 2 items
     set strength item 2 items]
  ]
 ]
 file-close
end

;; Helper procedure for looking up a node by node-id.
to-report get-node [id]
 report one-of nodes with [node-id = id]
end
