<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" ToolsVersion="4.0">
  <PropertyGroup>
    <ProductVersion>3.5</ProductVersion>
    <RootNamespace>Moshine.MessagePipeline</RootNamespace>
    <ProjectGuid>{5116EDC8-7BF4-4A3B-BA8B-9F875F54FAB0}</ProjectGuid>
    <OutputType>Library</OutputType>
    <AssemblyName>Moshine.MessagePipeline</AssemblyName>
    <AllowGlobals>False</AllowGlobals>
    <AllowLegacyWith>False</AllowLegacyWith>
    <AllowLegacyOutParams>False</AllowLegacyOutParams>
    <AllowLegacyCreate>False</AllowLegacyCreate>
    <AllowUnsafeCode>False</AllowUnsafeCode>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <TargetFramework>.NET5.0</TargetFramework>
    <Name>Moshine.MessagePipeline</Name>
    <RunPostBuildEvent>OnBuildSuccess</RunPostBuildEvent>
    <AssemblyVersion>2.0</AssemblyVersion>
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
    <NuGetReference Include="Newtonsoft.Json:[13.0.1]" />
    <NuGetReference Include="System.Threading.Tasks.Dataflow:[5.0.0]" />
    <ProjectReference Include="..\Moshine.MessagePipeline.Core\Moshine.MessagePipeline.Core.elements">
      <HintPath>..\Moshine.MessagePipeline.Core\bin\Debug\Moshine.MessagePipeline.Core.dll</HintPath>
      <Project>{D6FDDD36-602C-49C1-B399-30852F6F8B98}</Project>
      <ProjectFile>..\Moshine.MessagePipeline.Core\Moshine.MessagePipeline.Core.elements</ProjectFile>
    </ProjectReference>
    <NuGetReference Include="Microsoft.Extensions.Logging:[5.0.0]" />
  </ItemGroup>
  <ItemGroup>
    <Compile Include="Pipeline.pas" />
    <Compile Include="PipelineSerializer.pas" />
    <Compile Include="Properties\AssemblyInfo.pas" />
    <Compile Include="Response.pas" />
    <EmbeddedResource Include="Properties\Resources.resx">
      <Generator>ResXFileCodeGenerator</Generator>
    </EmbeddedResource>
    <Compile Include="Properties\Resources.Designer.pas" />
    <None Include="Properties\Settings.settings">
      <Generator>SettingsSingleFileGenerator</Generator>
    </None>
    <Compile Include="Properties\Settings.Designer.pas" />
    <Compile Include="MethodCallHelpers.pas" />
    <Compile Include="ActionInvokerHelpers.pas" />
    <None Include="Moshine.MessagePipeline.Nuspec" />
    <Compile Include="PipelineClient.pas" />
    <Compile Include="ParcelProcessor.pas" />
    <Compile Include="Scope\NonTransactionalScope.pas" />
    <Compile Include="Scope\TransactionalScope.pas" />
    <Compile Include="Scope\NonTransactionalScopeProvider.pas" />
    <Compile Include="Scope\TransactionalScopeProvider.pas" />
    <Compile Include="ParcelReceiver.pas" />
  </ItemGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Elements\RemObjects.Elements.Echoes.targets" />
  <PropertyGroup>
    <PreBuildEvent />
    <PostBuildEvent />
  </PropertyGroup>
</Project>