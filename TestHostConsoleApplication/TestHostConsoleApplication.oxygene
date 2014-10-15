<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
  <PropertyGroup>
    <ProductVersion>3.5</ProductVersion>
    <RootNamespace>TestHostConsoleApplication</RootNamespace>
    <ProjectGuid>{7d1fb0a8-9368-4648-b1c2-9902faddc82c}</ProjectGuid>
    <OutputType>exe</OutputType>
    <AssemblyName>TestHostConsoleApplication</AssemblyName>
    <AllowGlobals>False</AllowGlobals>
    <AllowLegacyWith>False</AllowLegacyWith>
    <AllowLegacyOutParams>False</AllowLegacyOutParams>
    <AllowLegacyCreate>False</AllowLegacyCreate>
    <AllowUnsafeCode>False</AllowUnsafeCode>
    <ApplicationIcon>Properties\App.ico</ApplicationIcon>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <TargetFrameworkVersion>v4.5</TargetFrameworkVersion>
    <Name>TestHostConsoleApplication</Name>
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
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="Microsoft.ServiceBus">
      <HintPath>..\packages\WindowsAzure.ServiceBus.2.4.4.0\lib\net40-full\Microsoft.ServiceBus.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="Microsoft.WindowsAzure.Configuration">
      <HintPath>..\packages\Microsoft.WindowsAzure.ConfigurationManager.2.0.3\lib\net40\Microsoft.WindowsAzure.Configuration.dll</HintPath>
      <Private>True</Private>
    </Reference>
    <Reference Include="mscorlib" />
    <Reference Include="RemObjects.Elements.Dynamic">
      <HintPath>C:\Program Files\RemObjects Software\Oxygene\Echoes\Reference Assemblies\RemObjects.Elements.Dynamic.dll</HintPath>
    </Reference>
    <Reference Include="StackExchange.Redis">
      <HintPath>..\packages\StackExchange.Redis.1.0.333\lib\net45\StackExchange.Redis.dll</HintPath>
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
    <Compile Include="Program.pas" />
    <Compile Include="Properties\AssemblyInfo.pas" />
    <Content Include="App.config">
      <SubType>Content</SubType>
    </Content>
    <Content Include="packages.config">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Properties\App.ico" />
    <EmbeddedResource Include="Properties\Resources.resx">
      <Generator>ResXFileCodeGenerator</Generator>
    </EmbeddedResource>
    <Compile Include="Properties\Resources.Designer.pas" />
    <None Include="Properties\Settings.settings">
      <Generator>SettingsSingleFileGenerator</Generator>
    </None>
    <Compile Include="Properties\Settings.Designer.pas" />
  </ItemGroup>
  <ItemGroup>
    <Folder Include="Properties\" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="..\Moshine.MessagePipeline\Moshine.MessagePipeline.oxygene">
      <Name>Moshine.MessagePipeline</Name>
      <Project>{5116edc8-7bf4-4a3b-ba8b-9f875f54fab0}</Project>
      <Private>True</Private>
      <HintPath>..\Moshine.MessagePipeline\bin\Debug\Moshine.MessagePipeline.dll</HintPath>
    </ProjectReference>
  </ItemGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Echoes.targets" />
</Project>