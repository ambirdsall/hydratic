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
(var title-font-size 48)

(defmacro in-window [title & forms]
  ~(do
     (,r/init-window ,window-width ,window-height ,title)
     # turns out raylib can crank through a game loop as simple as this one at 2K-7K fps
     # on my thinkpad, which is juuuuuuust a touch more than we need for static text
     (,r/set-target-fps 60)
     (def font (,r/load-font-ex
                 (font-path "InterVariable.ttf")
                 font-size))

     (def title-font (,r/load-font-ex
                       (font-path "InterVariable.ttf")
                       title-font-size))

     (defn text-width [text &opt is-title]
       (default is-title false)
       (def size (if is-title title-font-size font-size))
       (let [f (if is-title title-font font)
             [width _] (,r/measure-text-ex f text size letter-spacing)]
         width))

     (defn write [text x-and-y-positions color &opt size]
       (default size font-size)
       (let [f (if (= size title-font-size) title-font font)]
         (,r/draw-text-ex f text x-and-y-positions size letter-spacing color)))

     (defn write-ln! [text]
       (write text [x-margin (dyn :vertical-offset)] :green)
       (setdyn :vertical-offset (+ (dyn :vertical-offset) font-size line-spacing)))

     (defn write-cmd! [key-char text]
       (let [y-offset (dyn :vertical-offset)
             bracket-width (text-width "[")
             key-width (text-width key-char)
             prefix-width (text-width (string "[" key-char "] "))]
         (write "["
                [x-margin y-offset]
                :green)
         (write key-char
                [(+ x-margin bracket-width) y-offset]
                :yellow)
         (write "] "
                [(+ x-margin bracket-width key-width) y-offset]
                :green)
         (write text
                [(+ x-margin prefix-width) y-offset]
                :green))
       (setdyn :vertical-offset (+ (dyn :vertical-offset) font-size line-spacing)))

     (defn write-title! [text]
       (write text [x-margin (dyn :vertical-offset)] :green title-font-size)
       (setdyn :vertical-offset (+ (dyn :vertical-offset) title-font-size line-spacing)))

     (var donezo false)
     (defn donezo! [] (set donezo true))

     (while (not (or donezo (,r/window-should-close)))
       (setdyn :vertical-offset y-margin)
       (,r/begin-drawing)
       (,r/clear-background [0 0 0])
       (,r/draw-rectangle 0 0 ,window-width ,window-height :dark-gray)

       ,;forms

       (,r/end-drawing))
     (,r/close-window)))

(defn render-hydra! [title commands]
  (in-window
    title

    # seed `longest` with the title width, so we don't need to take any extra steps to
    # account for that later
    (var longest (text-width title :title-size))

    (write-title! title)
    (loop [[key spec] :pairs commands]
      (set longest (max
                     longest
                     (text-width (string "[" key "] " (spec :title)))))
      (write-cmd! (string key) (spec :title))
      (when (r/key-down? key) (set (spec :selected) true)))

    # Calculate window height accounting for:
    # - title at title-font-size + line-spacing
    # - N command lines at font-size + line-spacing each
    # - top and bottom y-margin
    (let [title-height (+ title-font-size line-spacing)
          commands-height (* (+ font-size line-spacing) (length commands))
          height (+ title-height
                    commands-height
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

(defn render-timed-banner! [banner-text]
  (let [start (os/time)]
    (in-window
      banner-text
      (let [width (+ (text-width banner-text :title) (* 2 x-margin))
            height (+ title-font-size (* 2 y-margin))
            elapsed (- (os/time) start)]
        (r/set-window-size width height)
        (when (< 1 elapsed) (donezo!)))
      (write-title! banner-text))))
