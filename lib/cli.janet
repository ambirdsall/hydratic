(use sh)
(import spork/json)

(defn words->str [words] (string/join words " "))

(defn json->hydra-spec [rawspec]
  # TODO validate the structure of respec
  # - it's a single top-level object
  # - ? :: it has a "title"
  # - single-letter keys map to objects with desc/cmd keys

  # just a little bit
  (def respec (json/decode rawspec))
  # ooh, baby

  (def spec @{})
  (def title (respec "title"))

  # now parse the whole-ass json spec into a (render-hydra! ...)
  (loop [kvs :pairs respec]
    (match kvs
      ["title" _]
      :did-that

      ([key @{"desc" desc "cmd" shell-string}] (= 1 (length key)))
      (put spec (keyword key)
             @{:desc desc
              :fn (fn [] ($ sh -c ,(string shell-string)))})))

  [title spec])
