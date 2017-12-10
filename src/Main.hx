
import Atom.commands;
import Atom.notifications;
import haxe.Timer;
import js.Browser.document;
import js.Error;
import js.node.Buffer;
import js.npm.SerialPort;
import om.color.space.RGB;

@:keep
class Main {

    static inline function __init__() untyped module.exports = Main;

    static var allowedDevices = [
        '74034313938351717211' // Arduino Mega
    ];

    static var controllers : Array<Controller>;
    static var color : RGB;
    static var settings : SettingsView;

    static function activate( state ) {

        trace( 'Atom-darkside ' );

        controllers = [];
        color = 0xffffff;

        if( state != null ) {
            if( state.color != null ) color = state.color;
        }

        Timer.delay( function(){

            searchControllers( function(?e,?controllers){

                if( e != null )
                    notifications.addError( e.message );

                else {

                    Main.controllers = controllers;

                    Timer.delay( function(){
                        changeColor( 0x0000ff  );
                    }, 500 );

                }
            });
        }, getConfigValue( 'startdelay' ) );

        settings = new SettingsView( color, changeColor );

        commands.add( 'atom-workspace', 'darkside:off', function(e) {
            changeColor( 0x000000 );
        } );
        commands.add( 'atom-workspace', 'darkside:darker', function(e) {
            changeColor( color.darker( 0.1 ) );
        } );
        commands.add( 'atom-workspace', 'darkside:lighter', function(e) {
            changeColor( color.lighter( 0.1 ) );
        } );
        commands.add( 'atom-workspace', 'darkside:settings', function(e) {
            settings.toggle();
        } );
    }

    static function deactivate() {
        settings.destroy();
        for( ctrl in controllers ) ctrl.disconnect();
    }

    static function serialize() {
        return { color: color };
    }

    static function changeColor( color : RGB ) {
        if( color == Main.color )
            return;
        Main.color = color;
        for( controller in controllers ) {
            controller.setColor( color, function(?e){
                //trace(e);
            } );
        }
    }

    static function provideService() {
        return {
            get : function() {
                return color;
            },
            set : function( color : Int, ?opts : Dynamic) {
                changeColor( color );
            }
        };
    }

    static function searchControllers( callback : ?Error->?Array<Controller>->Void ) {
        SerialPort.list( function(e,infos) {
            if( e != null ) callback( e ) else {
                var devices = new Array<SerialPortInfo>();
                for( dev in infos ) {
                    var allowed = false;
                    for( allowedDevice in allowedDevices ) {
                        if( dev.serialNumber == allowedDevice ) {
                            allowed = true;
                            break;
                        }
                    }
                    if( allowed )
                        devices.push( dev );
                }
                var n = 0;
                var controllers = new Array<Controller>();
                for( dev in devices ) {
                    var controller = new Controller( dev.comName, getConfigValue( 'baud_rate' ) );
                    controller.connect( function(e){
                        if( e != null ) {
                            callback( e );
                            return;
                        } else {
                            controllers.push( controller );
                        }
                        if( ++n == devices.length )
                            callback( controllers );
                    });
                }
            }
        });
    }

    static inline function getConfigValue<T>( id : String ) : T {
        return Atom.config.get( 'darkside.$id' );
    }

}
