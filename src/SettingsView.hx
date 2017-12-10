
import Atom.workspace;
import js.Browser.document;
import js.html.DivElement;
import om.color.space.RGB;

class SettingsView {

    public var element(default,null) : DivElement;

    var onChange : RGB->Void;
    var panel : atom.Panel;

    public function new( color : RGB, onChange : RGB->Void ) {

        this.onChange = onChange;

        element = document.createDivElement();
        element.classList.add( 'darkside-settings' );
        element.textContent = 'DARKSIDE';

        var input = document.createInputElement();
        input.type = 'color';
        input.value = Std.string(color);
        element.appendChild( input );

        input.addEventListener( 'input', handleColorInput, false );

        panel = workspace.addRightPanel( { item: element, visible: false } );
    }

    public inline function isOpen()
        return panel.isVisible();

    public inline function open()
        panel.show();

    public inline function close()
        panel.hide();

    public inline function toggle()
        isOpen() ? close() : open();

    public inline function destroy() {
        panel.destroy();
    }

    function handleColorInput(e) {
        //var info = om.color.ColorParser.parseHex( e.target.value );
        //trace(info);
        //var c : RGB = RGB.fromString(e.target.value);
        //trace(c);
        //var c : RGB = Std.parseInt( e.target.value );
        onChange( RGB.fromString( e.target.value ) );
    }

}
