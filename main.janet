(use sh)
(import jaylib :as r) # the "r" is for "raylib"
(import spork/json :as j) # why it's not "j" for "jaylib": json has no such fallback

(use ./lib/gui)

(defn- render-workspace-name! []
  (let [workspaces (j/decode ($<_ niri msg --json workspaces))
        active-space ((find |(get $ "is_focused") workspaces) "name")
        start (os/time)]
    (in-window
      "where the fuck am i tho"
      (let [width (+ (text-width active-space) (* 2 x-margin))
            height (+ font-size (* 2 y-margin))
            elapsed (- (os/time) start)]
        (r/set-window-size width height)
        (when (< 1 elapsed) (donezo!)))
      (write-ln! active-space 1))))

(defn- render-test-hydra! []
  (render-hydra!
    "My cool test hydra"
    {:a @{:title "thing a" :fn (fn [] ($ notify-send "hey hey my my")) }
     :b @{:title "thing b" :fn (fn [] ($ notify-send "you are")) }
     :s @{:title "go to sleep, little baby" :fn (fn [] ($ systemctl suspend))}}))

(defn main [& invocation]
  (match invocation
    [_ "test-hydra"] (render-test-hydra!)
    [_ "niri" "ws"] (render-workspace-name!)
    _ (render-test-hydra!)))

# Local Variables:
# ajrepl-start-cmd-line: ("jpm" "-l" "janet" "-s" "-d")
# End:
