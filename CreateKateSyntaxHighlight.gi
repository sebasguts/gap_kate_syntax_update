#! @Arguments path[, name][, is_documented]
#! @Returns nothing
#! @Description
#!  Creates a syntax highlight definition for kate, having all currently defined functions
#!  defined for highlighting.
#!  <A>path</A> specifies the output path for the syntax highlight definition file.
#!  <A>name</A> (optional) defines a suffix for the name of the language, i.e., the language
#!  will be displayed in Kate as GAP-<A>name</A>. If no name is given, the Kate language name
#!  will be GAP.
#!  If <A>is_documented</A> is <C>true</C>, only documented functions are specified for Syntax highlighting.
#!  Default is <C>false</C>.
CreateKateSyntaxHighlight := function( arg... )
    local name, documented, file_path, current_set_global_vars, current_set_functions,
          values_to_add, i, value_of_var, setter_name, tester_name, current_set_strings,
          complete_item_string, template, template_content,content, output, position;
    
    file_path := arg[ 1 ];
    
    if Length( arg ) = 2 then
        
        if IsBool( arg[ 2 ] ) then
            
            name := "";
            documented := arg[ 2 ];
            
        else
            
            name := arg[ 2 ];
            documented := false;
            
        fi;
        
    elif Length( arg ) = 3 then
        
        name := arg[ 2 ];
        documented := arg[ 3 ];
        
    else
        
        Error( "Wrong Arguments: Usage CreateKateSyntaxHighlight( file_path, [ name_extension ], [ only_documented ] );" );
        return;
        
    fi;
    
    if name <> "" then
        name := Concatenation( "-", name );
    fi;
    
    current_set_global_vars := NamesGVars();
    
    current_set_functions := Filtered( current_set_global_vars, i-> IsBoundGlobal( i ) and IsFunction( ValueGlobal( i ) ) );
    
    for i in [ "<", "=", "*", "+", "-", ".", ".:=", "/" ] do
        position := Position( current_set_functions, i );
        if position <> fail then
            Remove( current_set_functions, position );
        fi;
    od;
    
    if documented then
        current_set_functions := Filtered( current_set_functions, IsDocumentedWord );
    fi;
    
    values_to_add := [ ];
    
    for i in current_set_functions do
        
        value_of_var := ValueGlobal( i );
        
        
        ## FIXME: Probably only necessary if documented = true
        ## FIXME: Is there a possibility to find out if certain operations are attributes/properties
        if IsOperation( value_of_var ) then
            
            setter_name := Concatenation( "Set", i );
            tester_name := Concatenation( "Has", i );
            
            if not setter_name in current_set_functions and IsBoundGlobal( setter_name ) then
                
                Add( values_to_add, setter_name );
                
            fi;
            
            if not tester_name in current_set_functions and IsBoundGlobal( tester_name ) then
                
                Add( values_to_add, tester_name );
                
            fi;
            
        fi;
        
    od;
    
    current_set_functions := Concatenation( current_set_functions, values_to_add );
    
    current_set_strings := List( current_set_functions, i -> Concatenation( "			<item>", i, "</item>" ) );
    
    complete_item_string := JoinStringsWithSeparator( current_set_strings, "\n" );
    
    template := IO_File( "gap.xml.template" );
    template_content := Concatenation( IO_ReadLines( template ) );
    IO_Close( template );
    
    content := ReplacedString( template_content, "@@@Name@@@", name );
    content := ReplacedString( content, "@@@MHIGHLIGHT_ITEMS@@@", complete_item_string );
    
    output := IO_File( file_path, "w" );
    IO_Write( output, content );
    IO_Close( output );
    
end;
