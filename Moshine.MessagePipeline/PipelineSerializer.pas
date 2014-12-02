﻿namespace Moshine.MessagePipeline;

interface

uses
  System.Collections.Generic,
  System.IO,
  System.Linq,
  System.Runtime.Serialization,
  System.Text, 
  System.Xml;

type

  PipelineSerializer = public static class
  private
    method CreateSerializer<T>:DataContractSerializer;
  public
    method Serialize<T>(value:T):String;
    method Deserialize<T>(value:String):T;
 end;

implementation

method PipelineSerializer.Deserialize<T>(value:String):T;
begin
  var serializer := CreateSerializer<T>;

  var sReader:= new StringReader(value);
  var xReader := XmlReader.Create(sReader);
  exit serializer.ReadObject(xReader) as T;

end;

method PipelineSerializer.Serialize<T>(value:T):String;
begin
  if(not assigned(value))then
  begin
    exit String.Empty;
  end;

  var serializer := CreateSerializer<T>;

  var sWriter := new StringWriter;
  var xWriter := XmlWriter.Create(sWriter);
  serializer.WriteObject(xWriter,value);
  xWriter.Flush;
  exit sWriter.ToString;


end;

method PipelineSerializer.CreateSerializer<T>: DataContractSerializer;
begin
  var knownTypes := new List<&Type> ();
  knownTypes.Add(typeOf(List<Integer>));
  var serializer := new DataContractSerializer(typeOf(T), knownTypes);
  exit serializer;
end;


end.
