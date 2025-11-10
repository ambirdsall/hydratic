(use sh)
(import jaylib :as r) # the "r" is for "raylib"
(import spork/json :as j) # why it's not "j" for "jaylib": json has no such fallback

(use ./lib/gui)

(defn- render-timed-banner! [banner-text]
  (let [start (os/time)]
    (in-window
      "ok but where am i tho"
      (let [width (+ (text-width banner-text :title) (* 2 x-margin))
            height (+ title-font-size (* 2 y-margin))
            elapsed (- (os/time) start)]
        (r/set-window-size width height)
        (when (< 1 elapsed) (donezo!)))
      (write-title! banner-text))))

(defn- render-test-hydra! []
  (render-hydra!
    "My cool test hydra"
    {:a @{:title "thing a" :fn (fn [] ($ notify-send "hey hey my my")) }
     :b @{:title "thing b" :fn (fn [] ($ notify-send "you are")) }
     :s @{:title "go to sleep, little baby" :fn (fn [] ($ systemctl suspend))}}))

(defn- words->str [words] (string/join words " "))

(defn main [& invocation]
  (match invocation
    [_ "test-hydra"] (render-test-hydra!)
    [_ "timed-banner" & banner-text] (render-timed-banner! (words->str banner-text))
    _ (render-timed-banner! (words->str invocation))))

# Local Variables:
# ajrepl-start-cmd-line: ("jpm" "-l" "janet" "-s" "-d")
# End:
