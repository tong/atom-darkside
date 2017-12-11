
import Atom.workspace;
import haxe.Timer;
import js.Browser.console;
import js.Browser.document;
import js.html.DivElement;
import js.html.Element;
import js.html.InputElement;
import om.color.space.RGB;

class SettingsView {

    public var element(default,null) : DivElement;

    var color : RGB;
    var onChange : RGB->Void;
    var panel : atom.Panel;
    var preview : InputElement;

    public function new( color : RGB, onChange : RGB->Void, visible = false ) {

        this.color = color;
        this.onChange = onChange;

        element = document.createDivElement();
        element.classList.add( 'darkside-settings' );

        preview = document.createInputElement();
        preview.type = 'text';
        preview.classList.add( 'preview', 'input-text' );
        element.appendChild( preview );

        /*
        var input = document.createInputElement();
        input.type = 'checkbox';
        input.classList.add( 'input-toggle' );
        element.appendChild( input );
        //input.addEventListener( 'input', handleColorInput, false );
        */

        function createSlider( ?name : String, min = 0.0, max = 1.0, step = 0.01, value = 0.0 ) {
            var e = document.createInputElement();
            if( name != null ) {
                e.title = name;
                e.name = name;
            }
            e.type = 'range';
            e.classList.add( 'input-range' );
            e.min = Std.string( min );
            e.max = Std.string( max );
            e.step = Std.string( step );
            e.value = Std.string( value );
            return e;
        }

        var rgb = document.createElement( 'section' );
        rgb.appendChild( createSlider( 'r', 0, 255, 1, color.r ) );
        rgb.appendChild( createSlider( 'g', 0, 255, 1, color.g ) );
        rgb.appendChild( createSlider( 'b', 0, 255, 1, color.b ) );
        element.appendChild( rgb );
        rgb.addEventListener( 'input', function(e) {
            var v = Std.parseInt( e.target.value );
            try color = (color[Std.string(e.target.name)] = v) catch(e:Dynamic) {
                console.error( e.toString() );
                return;
            }
            setColor( color );
            onChange( color );
        } );

        var hsv = document.createElement( 'section' );
        hsv.appendChild( createSlider( 'h', 0, 359, 1, color.toHSV().h ) );
        hsv.appendChild( createSlider( 's', 0.0, 1.0, 0.01, color.toHSV().s ) );
        hsv.appendChild( createSlider( 'v', 0.0, 1.0, 0.01, color.toHSV().v ) );
        element.appendChild( hsv );
        /*
        hsv.addEventListener( 'input', function(e) {
            var v = Std.parseInt( e.target.value );
            color = color.toHSV()[Std.string(e.target.name)] = v;
            setColor( color );
            onChange( color );

            try color = (color[Std.string(e.target.name)] = v) catch(e:Dynamic) {
                console.error( e.toString() );
                return;
            }
            //color = color.toHSV()[]
            //preview.style.background = color.toCSS3();
            //onChange( color );
        } );
        */

        setColor( color );

        panel = workspace.addFooterPanel( { item: element, visible: visible } );
    }

    public inline function isOpen()
        return panel.isVisible();

    public inline function open()
        panel.show();

    public inline function close()
        panel.hide();

    public inline function toggle()
        isOpen() ? close() : open();

    public inline function destroy()
        panel.destroy();

    public function serialize()
        return { open: isOpen() };

    function setColor( c : RGB ) {
        this.color = c;
        var hex = c.toHex();
        preview.value = hex;
        preview.style.background = hex;
        //element.style.background = hex;
    }

}
