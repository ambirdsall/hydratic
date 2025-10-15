# TODO can I re-export jaylib utils?
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

(defmacro in-window [width height title & forms]
  # TODO calculate window height and width
  #   FOR 1-COLUMN:
  #   width:  (+ width of longest line + 2 * x-margin)
  #   height: (line height * (length commands))
  #          (r/set-window-size width height)
  #   FOR 2 COLUMN:
  #   2. (width of longest even-indexed line
  #       + width of longest odd-indexed line
  #       + 3 * x-margin)
  #
  #   maybe use 2-column iff there are 6+ commands and no line >, say,
  #     (* 0.4 r/get-screen-width))
  #
  ~(do
     (,r/init-window ,width ,height ,title)
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

     (defn write-ln! [text line]
       (let [y-offset (+ (* font-size (- line 1))
                           (* line-spacing (- line 1))
                         y-margin)]
         (write text [x-margin y-offset] :green)))

     (defn write-cmd! [key-char text line]
       (let [first (string/slice text 0 1)
             rest (string/slice text 1)
             y-offset (+ (* font-size (- line 1))
                           (* line-spacing (- line 1))
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
                :green)))

     (while (not (,r/window-should-close))
       (,r/begin-drawing)
       (,r/clear-background [0 0 0])

       ,;forms

       (,r/end-drawing))
     (,r/close-window)))

(def window-width 800)
(def window-height 800)
(def y-margin 10)
(def x-margin 10)
(def font-size 30)
(def letter-spacing 1)
(def line-spacing 10)
