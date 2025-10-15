(use sh)
(import jaylib :as r) # the "r" is for "raylib"
(import spork/json :as j) # why it's not "j" for "jaylib": json has no such fallback

(use ./lib/gui)

(defn- render-workspace-name! []
  (let [workspaces (j/decode ($<_ niri msg --json workspaces))
        active-space ((find |(get $ "is_focused") workspaces) "name")]
    (in-window
      window-width window-height "where the fuck am i tho"

      (r/draw-rectangle 0 0 window-width window-height :dark-gray)
      (write-ln! "um,,, hello?" 1)
      (write-ln! active-space 2))))

# TODO extract a `render-hydra!` macro
# TODO extract a `render-text-popup!` macro from that
(defn- render-test-hydra! []
  (def commands
    {:a @{:title "thing a" :fn (fn [] ($ notify-send "hey hey my my")) }
     :b @{:title "thing b" :fn (fn [] ($ notify-send "you are")) }
     :s @{:title "go to sleep, little baby" :fn (fn [] ($ systemctl suspend))}})

  (in-window
    window-width window-height "Example hydra popup window"

    (r/draw-rectangle 0 0 window-width window-height :dark-gray)

    (var line 1)
    (loop [[key spec] :pairs commands]
      (write-cmd! (string key) (spec :title) line)
      (when (r/key-down? key) (set (spec :selected) true))
      (set line (inc line)))
    # TODO maybe write some rando other lines to play around with raylib APIs? e.g. display clipboard contents.
    (write-ln! (string "we're cooking at " (string (r/get-fps)) " FPS") (inc line))
    (if-let [selected-cmd (find (fn [cmd] (cmd :selected)) (values commands))]
      (do (r/close-window)
        ((selected-cmd :fn))
        # let's not re-run the cmd at 60 FPS or whatever
        (set (selected-cmd :selected) nil)))))

(defn main [& invocation]
  (match invocation
    [_ "test-hydra"] (render-test-hydra!)
    [_ "niri" "ws"] (render-workspace-name!)
    _ (render-test-hydra!)))

# Local Variables:
# ajrepl-start-cmd-line: ("jpm" "-l" "janet" "-s" "-d")
# End:
