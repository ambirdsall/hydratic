(use jaylib)

(def window-width 800)
(def window-height 800)
(def y-margin 10)
(def x-margin 10)
(def font-size 30)
(def letter-spacing 1)
(def line-spacing 10)

(defn font-path [filename]
  (string (os/getenv "HOME") "/.local/share/fonts/" filename))

(defmacro in-window [width height title & forms]
  ~(do
     (,init-window ,width ,height ,title)
     (def font (,load-font-ex
                 (font-path "InterVariable.ttf")
                 font-size))

     (defn write [text x-and-y-positions color]
         (,draw-text-ex font text x-and-y-positions font-size letter-spacing color))

     (defn write! [text line]
       (let [first (string/slice text 0 1)
             rest (string/slice text 1)
             y-offset (+ (* font-size (- line 1))
                           (* line-spacing (- line 1))
                         y-margin)
             [first-width _] (measure-text-ex font first font-size letter-spacing)
             x-offset-rest (+ first-width x-margin letter-spacing)]
         (write first [x-margin y-offset] :yellow)
         (write rest [x-offset-rest y-offset] :green)))

     (while (not (,window-should-close))
       (,begin-drawing)
       (,clear-background [0 0 0])

       ,;forms

       (,end-drawing))
     (,close-window)))

(in-window window-width window-height "My cool transient gui"
  (draw-rectangle 0 0 window-width window-height :dark-gray)
  (write! "Hello world" 1)
  (write! "Raylib is craaazzzzy" 2))

# Local Variables:
# ajrepl-start-cmd-line: ("jpm" "-l" "janet" "-s" "-d")
# End:
