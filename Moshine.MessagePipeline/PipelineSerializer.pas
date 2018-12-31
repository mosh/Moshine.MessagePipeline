namespace Moshine.MessagePipeline;

uses
  System.Collections.Generic,
  System.IO,
  System.Linq,
  System.Runtime.Serialization,
  System.Text,
  System.Xml;

type

  PipelineSerializer<T> = public class
  private
    _serializer:DataContractSerializer;


  public

    constructor(parameterTypes:List<&Type>);
    begin
      var knownTypes := new List<&Type> ();
      knownTypes.Add(typeOf(List<Integer>));
      knownTypes.AddRange(parameterTypes);
      _serializer := new DataContractSerializer(typeOf(T), knownTypes);
    end;

    method Serialize<T>(value:T):String;
    begin
      if(not assigned(value))then
      begin
        exit String.Empty;
      end;

      var sWriter := new StringWriter;
      var xWriter := XmlWriter.Create(sWriter);
      _serializer.WriteObject(xWriter,value);
      xWriter.Flush;
      exit sWriter.ToString;


    end;

    method Deserialize<T>(value:String):T;
    begin

      var sReader:= new StringReader(value);
      var xReader := XmlReader.Create(sReader);
      exit _serializer.ReadObject(xReader) as T;

    end;
 end;

end.