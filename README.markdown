# GangstaWrap: Knuth-Plass linebreaking for Ruby

GangstaWrap is a basic implementation of the Knuth-Plass linebreaking
algorithm for breaking paragraphs of text into lines. It uses a total-fit
method to ensure consistency across the entire paragraph at once. The
algorithm is a simplified version of the one used in the TeX typesetting
system.

## References

The canonical reference for this algorithm is "Breaking Paragraphs Into
Lines", by Donald E. Knuth and Michael F. Plass, originally published in
Software Practice and Experience 11 (1981), pp. 1119-1184. It is reprinted
in the excellent monograph Digital Typography (Knuth 1999).

This implementation was inspired by Bram Stein's TypeSet project, an
implementation of Knuth-Plass in Javascript that uses HTML5 Canvas.

http://www.bramstein.com/projects/typeset/

## To Do

### Short-Term

* The Prawn drawing interface needs to be moved out of user code and into
  the library itself.

* Collect all of our constants and magic numbers and expose them somewhat to
  the user. Survey other software (TeX?) to harvest good starting values for
  these parameters.

* Fix the demerits calculation to the TeX "improved" formula (Digital
  Typography p. 154). Thanks to Bram Stein for pointing this out.

* Implement the looseness parameter q (algorithm "Choose the appropriate
  active node", Digital Typography p. 120).

* Add specs around the "god method" (`Paragraph#optimum_breakpoints`) and
  start to refactor it.

### Long-Term

* Bring this into Prawn, and integrate (if possible) with the Text::Box API.

* Ragged-right/left/center alignment.

* The tokenizer could be smarter; it should recognize more than just
  low-ASCII hyphens as hyphens / dashes, and it can get confused when
  whitespace and hyphens interact.

* Automatically relax the thresholds when the constraints cannot be
  satisfied? Or we could look into TeX's two-pass method (pp. 121-122).

* We don't hyphenate yet. That's another project altogether, but it won't be
  difficult to integrate.

## Acknowledgements

Thanks are due to the following individuals:

* Donald Knuth and Michael Plass created the original algorithm and data
  structures.

* Bram Stein wrote the aforementioned Javascript implementation of the
  Knuth-Plass algorithm. His code was helpful in exposing some of the darker
  corners of the original authors' description of the method.

## License

GangstaWrap is copyrighted free software, written by Brad Ediger. See the
LICENSE file for details.

