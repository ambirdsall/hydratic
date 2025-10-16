(import jaylib :as r) # the "r" is for "raylib"

# TODO make this play more nicely with other people's computers
# - vendor in a default font
# - make the font configurable via CLI arg
#   - handle vendored font and alias raylib's pixeltown default font
#   - define a robust font search path
#     - define separate lists of standard font directories on linux and macos
#     - dispatch to the correct one based on OS (presumably via a uname check)
(defn font-path [filename]
  (string (os/getenv "HOME") "/.local/share/fonts/" filename))

(var window-width 800)
(var window-height 800)
(var y-margin 10)
(var x-margin 10)
(var font-size 30)
(var letter-spacing 1)
(var line-spacing 10)

(defmacro in-window [title & forms]
  ~(do
     (,r/init-window ,window-width ,window-height ,title)
     # turns out raylib can crank through a game loop as simple as this one at 2K-7K fps
     # on my thinkpad, which is juuuuuuust a touch more than we need for static text
     (,r/set-target-fps 60)
     (def font (,r/load-font-ex
                 (font-path "InterVariable.ttf")
                 font-size))

     (defn text-width [text]
       (let [[width _] (,r/measure-text-ex font text font-size letter-spacing)]
         width))

     (defn write [text x-and-y-positions color]
         (,r/draw-text-ex font text x-and-y-positions font-size letter-spacing color))

     (defn write-ln! [text]
       (let [y-offset (+ (* font-size (- (dyn :line) 1))
                           (* line-spacing (- (dyn :line) 1))
                         y-margin)]
         (write text [x-margin y-offset] :green))
       (setdyn :line (inc (dyn :line))))

     (defn write-cmd! [key-char text]
       (let [first (string/slice text 0 1)
             rest (string/slice text 1)
             y-offset (+ (* font-size (- (dyn :line) 1))
                           (* line-spacing (- (dyn :line) 1))
                         y-margin)
             x-offset-rest (+ (text-width first) x-margin letter-spacing)]
         (write "["
                [x-margin y-offset]
                :green)
         (write key-char
                [(+ x-margin (text-width "[")) y-offset]
                :yellow)
         (write "] "
                [(+ x-margin (text-width (string "[" key-char))) y-offset]
                :green)
         (write text
                [(+ x-margin (text-width (string "[" key-char "] "))) y-offset]
                :green))
       (setdyn :line (inc (dyn :line))))

     (var donezo false)
     (defn donezo! [] (set donezo true))

     (while (not (or donezo (,r/window-should-close)))
       (setdyn :line 1)
       (,r/begin-drawing)
       (,r/clear-background [0 0 0])
       (,r/draw-rectangle 0 0 ,window-width ,window-height :dark-gray)

       ,;forms

       (,r/end-drawing))
     (,r/close-window)))

(defn render-hydra! [title commands]
  (in-window
    title

    (var longest 0)

    (loop [[key spec] :pairs commands]
      (set longest (max
                     longest
                     (text-width (string "[" key "] " (spec :title)))))
      (write-cmd! (string key) (spec :title))
      (when (r/key-down? key) (set (spec :selected) true)))

    (let [lines (length commands)
          height (+ (* font-size (length commands))
                    (* line-spacing (length commands))
                    (* 2 y-margin))
          width (+ longest (* 2 x-margin))]
      (set window-width width)
      (set window-height height)
      (r/set-window-size width height))

    (if-let [selected-cmd (find (fn [cmd] (cmd :selected)) (values commands))]
      (do (donezo!)
        ((selected-cmd :fn))
        # let's not re-run the cmd at 60 FPS or whatever
        (set (selected-cmd :selected) nil)))))
