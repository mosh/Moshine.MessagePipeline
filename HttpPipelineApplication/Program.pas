namespace HttpPipelineApplication;

interface

uses
  System.Linq, 
  Microsoft.Owin.Hosting;

implementation

begin
  var port := 5001;

  using WebApp.Start<Startup>(String.Format('http://localhost:{0}', port)) do
  begin
      Console.WriteLine(String.Format('On Port {0}', port));
      Console.ReadLine();
  end;
end.
