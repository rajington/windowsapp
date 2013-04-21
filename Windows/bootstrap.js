// important! JSCocoa doesn't do ARC. so if we do alloc, we need to do autorelease, old school

var coffeeToJS = function(coffee) {
  return CoffeeScript.compile(coffee, { bare: true });
};
