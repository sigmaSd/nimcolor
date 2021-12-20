import unittest
import color

test "effect":
  const
      a = $"constant rgb".rgb(100, 1, 1).rgbBg(200, 100, 0)
      b = $"constant color + style".purple().style(Bold).lightBlueBg().style(Italic)

  echo a
  echo b
  echo "yellow bold italic".yellow().bold().italic()
  echo "purple bold on lightBlue italic".purple().style(Bold).lightBlueBg().style(Italic)
  echo "lightBlue on purple bold".lightBlue().purpleBg().style(Bold)
