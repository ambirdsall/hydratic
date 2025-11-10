(use sh)
(import jaylib :as r) # the "r" is for "raylib"
(import spork/json :as j) # why it's not "j" for "jaylib": json has no such fallback

(use ./lib/cli)
(use ./lib/gui)

(defn- render-test-hydra! []
  (render-hydra!
    "My cool test hydra"
    {:a @{:desc "thing a" :fn (fn [] ($ notify-send "hey hey my my")) }
     :b @{:desc "thing b" :fn (fn [] ($ notify-send "you are")) }
     :s @{:desc "go to sleep, little baby" :fn (fn [] ($ systemctl suspend))}}))


(defn main [& invocation]
  (match invocation
    [_ "test-hydra"] (render-test-hydra!)
    [_ "timed-banner" & banner-text] (render-timed-banner! (words->str banner-text))
    _ (render-timed-banner! (words->str invocation))))

# Local Variables:
# ajrepl-start-cmd-line: ("jpm" "-l" "janet" "-s" "-d")
# End:
