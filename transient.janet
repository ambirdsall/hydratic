(use jaylib)

(def window-width 800)
(def window-height 800)
(def font-size 40)
(def spacing 1)

(defmacro in-window [width height title & forms]
  ~(do
     (,init-window ,width ,height ,title)

     (def font (,load-font-ex
                 (string (os/getenv "HOME") "/.local/share/fonts/InterVariable.ttf")
                 font-size))

     (defn write [text x-and-y-positions color]
         (,draw-text-ex font text x-and-y-positions font-size spacing color))

     (defn write! [text y-position]
       (let [first (string/slice text 0 1)
             [offset _] (measure-text-ex font first font-size spacing)
             rest (string/slice text 1)]
         (write first [10 y-position] :yellow)
         (write rest [(+ 10 offset spacing) y-position] :green))
       )

     (while (not (,window-should-close))
       (,begin-drawing)
       (,clear-background [0 0 0])

       ,;forms

       (,end-drawing))
     (,close-window)))

(in-window window-width window-height "My cool transient gui"
  (draw-rectangle 0 0 window-width window-height :dark-gray)
  (write! "Hello world" 10)
  (write! "Raylib is craaazzzzy" 50))

# Local Variables:
# ajrepl-start-cmd-line: ("jpm" "-l" "janet" "-s" "-d")
# End:
