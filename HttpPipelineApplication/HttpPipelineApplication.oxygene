<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
  <PropertyGroup>
    <ProductVersion>3.5</ProductVersion>
    <ProjectGuid>{fc16b7a3-65c2-4175-8bf1-0d5c885b236a}</ProjectGuid>
    <RootNamespace>HttpPipelineApplication</RootNamespace>
    <StartupClass />
    <OutputType>Exe</OutputType>
    <AssemblyName>HttpPipelineApplication</AssemblyName>
    <AllowGlobals>False</AllowGlobals>
    <AllowLegacyWith>False</AllowLegacyWith>
    <AllowLegacyOutParams>False</AllowLegacyOutParams>
    <AllowLegacyCreate>False</AllowLegacyCreate>
    <AllowUnsafeCode>False</AllowUnsafeCode>
    <ApplicationIcon>App.ico</ApplicationIcon>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <TargetFrameworkVersion>v4.5.2</TargetFrameworkVersion>
    <Name>HttpPipelineApplication</Name>
    <DefaultUses />
    <InternalAssemblyName />
    <TargetFrameworkProfile />
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
    <Optimize>false</Optimize>
    <OutputPath>.\bin\Debug</OutputPath>
    <DefineConstants>DEBUG;TRACE;</DefineConstants>
    <GeneratePDB>True</GeneratePDB>
    <GenerateMDB>True</GenerateMDB>
    <EnableAsserts>True</EnableAsserts>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <RegisterForComInterop>False</RegisterForComInterop>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <EnableUnmanagedDebugging>False</EnableUnmanagedDebugging>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
    <Optimize>true</Optimize>
    <OutputPath>.\bin\Release</OutputPath>
    <GeneratePDB>False</GeneratePDB>
    <GenerateMDB>False</GenerateMDB>
    <EnableAsserts>False</EnableAsserts>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <StartMode>Project</StartMode>
    <RegisterForComInterop>False</RegisterForComInterop>
    <CpuType>anycpu</CpuType>
    <RuntimeVersion>v25</RuntimeVersion>
    <XmlDoc>False</XmlDoc>
    <XmlDocWarningLevel>WarningOnPublicMembers</XmlDocWarningLevel>
    <EnableUnmanagedDebugging>False</EnableUnmanagedDebugging>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="Autofac">
      <HintPath>..\packages\Autofac.3.5.2\lib\net40\Autofac.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Elmah">
      <HintPath>..\packages\elmah.corelibrary.1.2.2\lib\Elmah.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Microsoft.Owin">
      <HintPath>..\packages\Microsoft.Owin.3.0.0\lib\net45\Microsoft.Owin.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Microsoft.Owin.Host.HttpListener">
      <HintPath>..\packages\Microsoft.Owin.Host.HttpListener.3.0.0\lib\net45\Microsoft.Owin.Host.HttpListener.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Microsoft.Owin.Hosting">
      <HintPath>..\packages\Microsoft.Owin.Hosting.3.0.0\lib\net45\Microsoft.Owin.Hosting.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Microsoft.ServiceBus">
      <HintPath>..\packages\WindowsAzure.ServiceBus.2.4.9.0\lib\net40-full\Microsoft.ServiceBus.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Microsoft.WindowsAzure.Configuration">
      <HintPath>..\packages\Microsoft.WindowsAzure.ConfigurationManager.2.0.3\lib\net40\Microsoft.WindowsAzure.Configuration.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="mscorlib" />
    <Reference Include="Nancy">
      <HintPath>..\packages\Nancy.0.23.2\lib\net40\Nancy.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Nancy.Bootstrappers.Autofac">
      <HintPath>..\packages\Nancy.Bootstrappers.Autofac.0.23.2\lib\net40\Nancy.Bootstrappers.Autofac.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Nancy.Elmah">
      <HintPath>..\packages\Nancy.Elmah.0.1.8\lib\net40\Nancy.Elmah.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Nancy.Owin">
      <HintPath>..\packages\Nancy.Owin.0.23.2\lib\net40\Nancy.Owin.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Newtonsoft.Json">
      <HintPath>..\packages\Newtonsoft.Json.6.0.6\lib\net45\Newtonsoft.Json.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Owin">
      <HintPath>..\packages\Owin.1.0\lib\net40\Owin.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Echoes">
      <HintPath>C:\Program Files\RemObjects Software\Oxygene\Echoes\Reference Assemblies\RemObjects.Elements.Dynamic.dll</HintPath>
    </Reference>
    <Reference Include="StackExchange.Redis">
      <HintPath>..\packages\StackExchange.Redis.1.0.371\lib\net45\StackExchange.Redis.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="System" />
    <Reference Include="System.Configuration">
      <HintPath>C:\Program Files\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.5\System.Configuration.dll</HintPath>
    </Reference>
    <Reference Include="System.Data" />
    <Reference Include="System.Runtime.Serialization" />
    <Reference Include="System.ServiceModel" />
    <Reference Include="System.Xml" />
    <Reference Include="System.Core">
      <RequiredTargetFramework>3.5</RequiredTargetFramework>
    </Reference>
    <Reference Include="System.Xml.Linq">
      <RequiredTargetFramework>3.5</RequiredTargetFramework>
    </Reference>
    <Reference Include="System.Data.DataSetExtensions">
      <RequiredTargetFramework>3.5</RequiredTargetFramework>
    </Reference>
  </ItemGroup>
  <ItemGroup>
    <Compile Include="Extensions\NancyExtensions.pas" />
    <Compile Include="Modules\SomeModule.pas" />
    <Compile Include="Program.pas" />
    <Compile Include="Services\SomeService.pas" />
    <Compile Include="SomeBootstrapper.pas" />
    <Compile Include="Startup.pas" />
    <Content Include="app.config">
      <SubType>Content</SubType>
    </Content>
    <Content Include="App.ico" />
    <Content Include="App_Readme\Elmah.txt">
      <SubType>Content</SubType>
    </Content>
    <Content Include="packages.config">
      <SubType>Content</SubType>
    </Content>
  </ItemGroup>
  <ItemGroup>
    <Folder Include="App_Readme\" />
    <Folder Include="Modules" />
    <Folder Include="Extensions" />
    <Folder Include="Services" />
    <Folder Include="Properties\" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\Moshine.MessagePipeline.Core\Moshine.MessagePipeline.Core.elements">
      <Name>Moshine.MessagePipeline.Core</Name>
      <Project>{d6fddd36-602c-49c1-b399-30852f6f8b98}</Project>
      <Private>True</Private>
      <HintPath>..\Moshine.MessagePipeline.Core\bin\Debug\Moshine.MessagePipeline.Core.dll</HintPath>
    </ProjectReference>
    <ProjectReference Include="..\Moshine.MessagePipeline.Transports.ServiceBus\Moshine.MessagePipeline.Transports.ServiceBus.elements">
      <Name>Moshine.MessagePipeline.Transports.ServiceBus</Name>
      <Project>{5341e3c0-40ef-415c-9517-eb3c8a2eff98}</Project>
      <Private>True</Private>
      <HintPath>..\Moshine.MessagePipeline.Transports.ServiceBus\bin\Debug\Moshine.MessagePipeline.Transports.ServiceBus.dll</HintPath>
    </ProjectReference>
    <ProjectReference Include="..\Moshine.MessagePipeline\Moshine.MessagePipeline.oxygene">
      <Name>Moshine.MessagePipeline</Name>
      <Project>{5116edc8-7bf4-4a3b-ba8b-9f875f54fab0}</Project>
      <Private>True</Private>
      <HintPath>..\Moshine.MessagePipeline\bin\Debug\Moshine.MessagePipeline.dll</HintPath>
    </ProjectReference>
  </ItemGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Elements\RemObjects.Elements.Echoes.targets" />
  <PropertyGroup>
    <PreBuildEvent />
  </PropertyGroup>
</Project>