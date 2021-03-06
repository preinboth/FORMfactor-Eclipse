class ZCL_FORMFACTOR_COMMAND definition
  public
  inheriting from CL_QUICKFIX_ADT_RES_APPLY_OBJ
  create public .

public section.
protected section.

  data MO_BLACKBOARD type ref to CL_ART_BLACKBOARD .

  methods BUILD_CODE
    returning
      value(RV_CONTENT) type STRING .
  methods FIX1
    returning
      value(RI_PROPOSAL) type ref to IF_QUICKFIX_RESULT .
  methods FIX2
    returning
      value(RI_PROPOSAL) type ref to IF_QUICKFIX_RESULT .
  methods INITIALIZE
    importing
      !II_QUICKFIX type ref to IF_QUICKFIX_SOURCE_OBJECT .

  methods APPLY_OBJ
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_FORMFACTOR_COMMAND IMPLEMENTATION.


METHOD apply_obj.

  initialize( quickfix_source_object ).

  CASE evaluation_result->get_uri( ).
    WHEN '/sap/bc/adt/zzformfactor/fix1'.
      proposal_result = fix1( ).
    WHEN '/sap/bc/adt/zzformfactor/fix2'.
      proposal_result = fix2( ).
    WHEN OTHERS.
      ASSERT 1 = 1 + 1.
  ENDCASE.

ENDMETHOD.


METHOD build_code.

  CONSTANTS: lc_newline TYPE abap_char1 VALUE cl_abap_char_utilities=>newline.

  DATA: lv_source TYPE string,
        lt_source TYPE rswsourcet.


  DATA(li_procedure) = mo_blackboard->get_surrounding_procedure( ).

  rv_content = |CLASS lcl_app DEFINITION.{ lc_newline }|.
  rv_content = |{ rv_content }  PUBLIC SECTION.{ lc_newline }|.
  rv_content = |{ rv_content }    CLASS-METHODS: FOO.{ lc_newline }|.
  rv_content = |{ rv_content }ENDCLASS.{ lc_newline }{ lc_newline }|.

  rv_content = |{ rv_content }CLASS lcl_app IMPLEMENTATION.{ lc_newline }|.
  rv_content = |{ rv_content }METHOD { li_procedure->name }.{ lc_newline }|.

* todo, this only seems to work if the source code is saved
  DATA(ls_range) = li_procedure->procedure_node->source_position->range.
  mo_blackboard->get_source_object( )->get_source_code( IMPORTING source_code = lt_source ).
  DELETE lt_source TO ls_range-start-row.
  ls_range-end-row = ls_range-end-row - ls_range-start-row.
  DELETE lt_source FROM ls_range-end-row.

  CONCATENATE LINES OF lt_source INTO lv_source SEPARATED BY lc_newline.
  rv_content = |{ rv_content }{ lv_source }|.

  rv_content = |{ rv_content }ENDMETHOD.{ lc_newline }|.
  rv_content = |{ rv_content }ENDCLASS.{ lc_newline }{ lc_newline }|.

ENDMETHOD.


METHOD fix1.

  DATA(li_procedure) = mo_blackboard->get_surrounding_procedure( ).
  ASSERT li_procedure IS BOUND.

  DATA(lv_content) = build_code( ).

* lo_procedure->procedure_node->source_position->span(
*   lo_procedure->procedure_node->source_position->get_end_position( ) )
  DATA(li_delta) = cl_art_delta_factory=>create_delta(
    i_source_position = li_procedure->procedure_node->source_position->get_start_position( )
    i_content         = lv_content ).
  ri_proposal = mo_blackboard->get_qfix_result( ).
  ri_proposal->add_delta( li_delta ).

ENDMETHOD.


METHOD fix2.

* todo
  ASSERT 1 = 1 + 1.

ENDMETHOD.


METHOD initialize.

  mo_blackboard = cl_art_blackboard=>create( ).
  mo_blackboard->set_source_object( ii_quickfix ).
  cl_art_contrib_scan_result=>create( mo_blackboard
    )->if_art_blackboard_contributor~contribute( ).
  cl_art_contrib_selection_type=>create( mo_blackboard
    )->if_art_blackboard_contributor~contribute( ).

ENDMETHOD.
ENDCLASS.