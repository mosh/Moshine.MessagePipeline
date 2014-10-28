namespace HttpPipelineApplication.Extensions;

interface

uses 
  System.IO,
  System.Collections.Generic,
  Moshine.MessagePipeline,
  Nancy.IO, 
  Newtonsoft.Json;

extension method RequestStream.AsDomainObject : DynamicDomainObject;


implementation

extension method RequestStream.AsDomainObject : DynamicDomainObject;
begin
  using reader := new StreamReader(self) do
  begin
    var content := reader.ReadToEnd;
    var valueDictionary :=  JsonConvert.DeserializeObject<Dictionary<String,Object>>(content);
    exit new DynamicDomainObject(valueDictionary);
  end;

end;

end.
