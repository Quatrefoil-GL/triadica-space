
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |touch-control/
  :entries $ {}
  :files $ {}
    |app.3d $ {}
      :defs $ {}
        |screen-vec $ quote
          def screen-vec $ [] 200 0 1000
        |transform-3d $ quote
          defn transform-3d (point)
            let
                x $ nth point 0
                y $ negate (nth point 1)
                z $ nth point 2
                a $ nth screen-vec 0
                b $ negate (nth screen-vec 1)
                c $ nth screen-vec 2
                L2 $ + (* a a) (* c c)
                L $ sqrt L2
                r $ wo-log
                  /
                    + (* a x) (* c z)
                    + (* a a) (* c c)
                y' $ /
                  *
                    - y $ * b r
                    sqrt $ + 1
                      / (* b b) L2
                  + r $ / y L2
                z' $ negate r
                x' $ /
                  * L $ - (* x c) (* z a)
                  + (* a x) (* c z)
              map ([] x' y' z')
                fn (p) p
      :ns $ quote (ns app.3d)
    |app.config $ {}
      :defs $ {}
        |dev? $ quote
          def dev? $ = "\"dev" (get-env "\"mode" "\"release")
        |inline-shader $ quote
          defmacro inline-shader (name)
            read-file $ str "\"shaders/" name
      :ns $ quote (ns app.config)
    |app.core $ {}
      :defs $ {}
        |&v+ $ quote
          defn &v+ (a b)
            let[] (x y z) a $ let[] (x2 y2 z2) b
              [] (&+ x x2) (&+ y y2) (&+ z z2)
        |*tmp-changes $ quote (defatom *tmp-changes nil)
        |half-pi $ quote
          def half-pi $ * 0.5 &PI
        |handle-key-event $ quote
          defn handle-key-event (event)
            let
                angle @*viewer-angle
                key $ .-key event
                shift? $ .-shiftKey event
              case-default key nil
                "\"ArrowDown" $ if shift?
                  tween-move-camera! $ [] :shift -1
                  tween-move-camera! $ [] :move 0 -2 0
                "\"ArrowUp" $ if shift?
                  tween-move-camera! $ [] :shift 1
                  tween-move-camera! $ [] :move 0 2 0
                "\"a" $ tween-move-camera! ([] :angle 0.04)
                "\"d" $ tween-move-camera! ([] :angle -0.04)
                "\"b" $ tween-move-camera!
                  [] :angle 1.653959 $ ; "\"manual value for turn back"
                "\"w" $ &let (a @*viewer-angle)
                  tween-move-camera! $ [] :move
                    &* 4 $ cos a
                    , 0
                      &* -4 $ sin a
                "\"s" $ &let (a @*viewer-angle)
                  tween-move-camera! $ [] :move
                    &* -2 $ cos a
                    , 0
                      &* 2 $ sin a
                "\"ArrowLeft" $ &let
                  a $ &+ @*viewer-angle (&/ &PI 2)
                  tween-move-camera! $ [] :move
                    &* 1 $ cos a
                    , 0
                      &* -1 $ sin a
                "\"ArrowRight" $ &let
                  a $ &- @*viewer-angle (&/ &PI 2)
                  tween-move-camera! $ [] :move
                    &* 1 $ cos a
                    , 0
                      &* -1 $ sin a
        |hclx $ quote
          defn hclx (h c l) (hcl-to-hex h c l)
        |hslx $ quote
          defn hslx (h s l)
            let
                c $ new THREE/Color
              .!getHex $ .!setHSL c (/ h 360) (/ s 100) (/ l 100)
        |move-viewer-by! $ quote
          defn move-viewer-by! (x0 y0 z0)
            let-sugar
                camera $ println "\"TODO CAmera"
                ([] dx dy dz) (to-viewer-axis x0 y0 z0)
                position $ .-position camera
                x $ &+ (.-x position) dx
                y $ &+ (.-y position) dy
                z $ &+ (.-z position) dz
              ; println ([] x0 y0 z0) |=> $ [] dx dy dz
              set! (.-x position) x
              set! (.-y position) y
              set! (.-z position) z
              println "\"CAMERA"
              println "\"TODO RENDER"
        |new-lookat-point $ quote
          defn new-lookat-point ()
            ; let-sugar
                camera $ j
                position $ .-position camera
                x2 $ &+ (.-x position)
                  &* 4 $ cos @*viewer-angle
                y2 $ &+ (.-y position) (&* 0.2 @*viewer-y-shift)
                z2 $ &+ (.-z position)
                  &* -4 $ sin @*viewer-angle
              println "\"lookat" x2 y2 z2
            println "\"new lookat point"
        |on-control-event $ quote
          defn on-control-event (elapsed states delta)
            let
                l-move $ map (:left-move states) refine-strength
                r-move $ map (:right-move states) refine-strength
                r-delta $ :right-move delta
                l-delta $ :left-move delta
                left-a? $ :left-a? states
                right-b? $ :right-b? states
                left-b? $ :left-b? states
              ; println "\"L" l-move "\"R" r-move
              when
                not= 0 $ nth l-move 1
                move-viewer-by! 0 0 $ negate
                  * 0.6 elapsed $ nth l-move 1
              when
                not= 0 $ nth l-move 0
                rotate-viewer-by! $ * -0.01 elapsed (nth l-move 0)
              when
                and (not left-a?) (not left-b?)
                  not= ([] 0 0) r-move
                move-viewer-by!
                  * 0.4 elapsed $ nth r-move 0
                  * 0.4 elapsed $ nth r-move 1
                  , 0
              when
                and left-a? $ not= 0 (nth r-delta 1)
                shift-viewer-by! $ * 1 (nth r-delta 1) elapsed
              when
                and left-a? $ not= 0 (nth r-delta 0)
                rotate-viewer-by! $ * -0.1 (nth r-delta 0) elapsed
              when (and left-b? right-b?)
                let
                    shift @*viewer-y-shift
                  cond
                      < shift -0.06
                      shift-viewer-by! $ * 2 elapsed
                    (> shift 0.06)
                      shift-viewer-by! $ * -2 elapsed
                    (< (js/Math.abs shift) 0.06)
                      shift-viewer-by! false
                    true nil
        |refine-strength $ quote
          defn refine-strength (x)
            &* x $ sqrt
              js/Math.abs $ &* x 0.02
        |rotate-viewer-by! $ quote
          defn rotate-viewer-by! (x)
            let
                camera $ println "\"CAMERA"
              swap! *viewer-angle &+ x
              println "\"CONFIG CAMERA"
              println "\"RENDER"
        |shift-viewer-by! $ quote
          defn shift-viewer-by! (x)
            let
                camera $ println "\"GLOBAL CAMERA"
              if (= x false) (reset! *viewer-y-shift 0)
                swap! *viewer-y-shift &+ $ * 2 x
              println "\"CONFIG CAMERA"
              println "\"COMPONENT"
        |to-viewer-axis $ quote
          defn to-viewer-axis (x y z)
            let
                length $ sqrt
                  + (pow x 2) (pow y 2) (pow z 2)
                angle @*viewer-angle
                project-distance 20
                shift @*viewer-y-shift
                v-angle $ js/Math.atan (/ shift project-distance)
                from-y $ []
                  -> y
                    * $ js/Math.cos (+ v-angle half-pi)
                    * $ js/Math.cos angle
                  -> y $ *
                    js/Math.sin $ + v-angle half-pi
                  -> y
                    * $ js/Math.cos (+ v-angle half-pi)
                    * $ js/Math.sin angle
                    negate
                from-x $ wo-log
                  []
                    -> x $ *
                      js/Math.cos $ - angle half-pi
                    , 0 $ -> x
                      * $ js/Math.sin (- angle half-pi)
                      negate
                from-z $ []
                  -> z (negate)
                    * $ js/Math.cos v-angle
                    * $ js/Math.cos angle
                  -> z (negate)
                    * $ js/Math.sin v-angle
                  -> z (negate)
                    * $ js/Math.cos v-angle
                    * $ js/Math.sin angle
                    negate
              -> from-x (&v+ from-y) (&v+ from-z)
        |tween-call $ quote
          defn tween-call (n d f)
            &doseq
              i $ range 1 n
              js/setTimeout
                fn () $ f i
                * d i
        |tween-move-camera! $ quote
          defn tween-move-camera! (control)
            key-match control
                :shift shift
                tween-call 20 5 $ fn (i)
                  do
                    swap! *viewer-y-shift &+ $ / shift 10
                    println "\"look at" $ new-lookat-point
                    println "\"call render"
              (:angle angle)
                tween-call 20 5 $ fn (i)
                  swap! *viewer-angle &+ $ / angle 10
                  do
                    println "\"look at" $ new-lookat-point
                    println "\"call render"
              (:move dx dy dz)
                tween-call 20 5 $ fn (i)
                  let-sugar
                      position $ println "\"TODO POSIITON"
                      x $ &+ (.-x position) (/ dx 10)
                      y $ &+ (.-y position) (/ dy 10)
                      z $ &+ (.-z position) (/ dz 10)
                    set! (.-x position) x
                    set! (.-y position) y
                    set! (.-z position) z
                    println "\"look at" $ new-lookat-point
                    println "\"call render"
              _ $ println "\"unknown camera control:" control
      :ns $ quote
        ns quatrefoil.core $ :require
          touch-control.core :refer $ render-control! control-states start-control-loop! clear-control-loop!
          "\"@quatrefoil/utils" :refer $ hcl-to-hex
          app.global :refer $ *viewer-angle *viewer-y-shift
    |app.global $ {}
      :defs $ {}
        |*viewer-angle $ quote
          defatom *viewer-angle $ &/ &PI 2
        |*viewer-y-shift $ quote (defatom *viewer-y-shift 0)
      :ns $ quote (ns app.global)
    |app.main $ {}
      :defs $ {}
        |canvas $ quote
          def canvas $ js/document.querySelector "\"canvas"
        |main! $ quote
          defn main! ()
            twgl/setDefaults $ js-object (:attribPrefix "\"a_")
            -> canvas .-width $ set! js/window.innerWidth
            -> canvas .-height $ set! js/window.innerHeight
            render-canvas
            render-control!
            start-control-loop! 10 on-control-event
            set! js/window.onkeydown handle-key-event
        |reload! $ quote
          defn reload! () $ if (nil? build-errors)
            do (render-canvas) (replace-control-loop! 10 on-control-event) (println "\"TODO..") (hud! "\"ok~" "\"OK")
            hud! "\"error" build-errors
      :ns $ quote
        ns app.main $ :require ("\"./calcit.build-errors" :default build-errors) ("\"bottom-tip" :default hud!)
          app.config :refer $ dev? inline-shader
          "\"twgl.js" :as twgl
          touch-control.core :refer $ render-control! control-states start-control-loop! clear-control-loop! replace-control-loop!
          app.core :refer $ handle-key-event on-control-event
          app.3d :refer $ transform-3d
          app.render :refer $ render-canvas
    |app.render $ {}
      :defs $ {}
        |move-point $ quote
          defn move-point (p)
            -> p
              map $ fn (i) (* i 800)
              update 1 $ fn (y) (+ y 20)
              update 2 $ fn (z) (- z 1000)
        |render-canvas $ quote
          defn render-canvas () $ let
              canvas $ js/document.querySelector "\"canvas"
              gl $ .!getContext canvas "\"webgl"
              arrays $ js-object
                :position $ .!createAugmentedTypedArray twgl/primitives 3 16
                :indices $ js-array 0 1 1 2 2 3 3 0 0 4 1 5 2 6 3 7 4 5 5 6 6 7 7 4
              points $ ->
                [] ([] -0.5 -0.5 0) ([] -0.5 0.5 0) ([] 0.5 0.5 0) ([] 0.5 -0.5 0) ([] -0.5 -0.5 -1) ([] -0.5 0.5 -1) ([] 0.5 0.5 -1) ([] 0.5 -0.5 -1)
                map $ fn (p)
                  transform-3d $ move-point p
            loop
                idx 0
                xs points
              println idx
              if
                not $ empty? xs
                let
                    p $ first xs
                  -> arrays .-position $ aset
                    + 0 $ * 3 idx
                    nth p 0
                  -> arrays .-position $ aset
                    + 1 $ * 3 idx
                    nth p 1
                  -> arrays .-position $ aset
                    + 2 $ * 3 idx
                    nth p 2
                  recur (+ idx 1) (rest xs)
            js/console.log "\"position" $ .-position arrays
            println "\"console.log" "\"demo"
            let
                vs $ inline-shader "\"shape.vert"
                fs $ inline-shader "\"shape.frag"
                program-info $ twgl/createProgramInfo gl (js-array vs fs)
                buffer-info $ twgl/createBufferInfoFromArrays gl arrays
                offsets $ js-array 0 0 0 1
                uniforms $ js-object (:offsets offsets)
              twgl/resizeCanvasToDisplaySize $ .-canvas gl
              .!viewport gl 0 0 (-> gl .-canvas .-width) (-> gl .-canvas .-height)
              .!enable gl $ .-DEPTH_TEST gl
              .!enable gl $ .-CULL_FACE gl
              .!clearColor gl 0 0 0 1
              .!clear gl $ or (.-COLOR_BUFFER_BIT gl) (.-DEPTH_BUFFER_BIT gl)
              .!useProgram gl $ .-program program-info
              twgl/setBuffersAndAttributes gl program-info buffer-info
              twgl/setUniforms gl buffer-info uniforms
              twgl/drawBufferInfo gl buffer-info $ .-LINES gl
              ; twgl/drawBufferInfo gl buffer-info $ .-TRIANGLES gl
              println "\"called"
      :ns $ quote
        ns app.render $ :require ("\"twgl.js" :as twgl)
          app.3d :refer $ transform-3d
          app.config :refer $ inline-shader
