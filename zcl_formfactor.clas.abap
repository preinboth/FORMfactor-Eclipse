class ZCL_FORMFACTOR definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_QUICKFIX_EVALUATION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FORMFACTOR IMPLEMENTATION.


METHOD if_quickfix_evaluation~evaluate.

* todo

  DATA: lv_foo TYPE i.

  lv_foo = 2.

ENDMETHOD.
ENDCLASS.