class Card
  class VegaChart
    class VerticalBars < VegaChart
      def scales
        [x_scale, y_scale, color_scale]
      end

      def x_scale
        { name: "x",
          type: "band",
          range: "width",
          domain: { data: "table", field: "x" } }
      end

      def y_scale
        { name: "y",
          type: y_type,
          range: "height",
          domain: { data: "table", field: "y" },
          round: true }
      end

      def y_type
        @y_range.span > 100 ? "sqrt" : "linear"
      end

      def x_axis
        { orient: "bottom", scale: "x", title: "Values",
          encode: diagonalize(axes_encode) }
      end

      def y_axis
        hash = { orient: "left", scale: "y",
                 title: @format.rate_subjects,
                 encode: axes_encode }
        hash[:tickCount] = y_tick_count if y_tick_count
        hash
      end

      # If the maximal value is less than 8 then vega shows
      # non-integers labels. We have to reduce the number of ticks
      # to the maximal value to avoid that
      # @max_ticks is a config option
      def y_tick_count
        return @max_ticks if @y_range.max && @y_range.max >= 8
        [@y_range.max, @max_ticks].compact.min
      end
    end
  end
end
