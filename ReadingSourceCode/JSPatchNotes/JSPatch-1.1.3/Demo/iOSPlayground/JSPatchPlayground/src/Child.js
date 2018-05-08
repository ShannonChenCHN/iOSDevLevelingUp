require('NSObject');

defineClass('Grandparent: NSObject', {
  one: function() {
    _OC_log('Grandparent One\n');
  }
});


defineClass('Parent: Grandparent', {
  one: function() {
    _OC_log('Parent One\n');
  },

  two: function() {
    self.one();
    self.super().one();
  }
});


defineClass('Child: Parent', {
  one: function() {
    _OC_log('Child One\n');
  }
});
