namespace Moshine.MessagePipeline.Cache;

uses 
  System.Runtime.Caching;

type

  RegionMemoryCache = public class(MemoryCache)
  public
    constructor RegionMemoryCache;
    begin
      inherited constructor('defaultCustomCache');
    end;

    method &Set(item: CacheItem; policy: CacheItemPolicy); override;
    begin
      &Set(item.Key, item.Value, policy, item.RegionName)
    end;

    method &Set(key: String; value: Object; absoluteExpiration: DateTimeOffset; regionName: String := nil); override;
    begin
      &Set(key, value, new CacheItemPolicy( AbsoluteExpiration := absoluteExpiration), regionName)
    end;

    method &Set(key: String; value: Object; policy: CacheItemPolicy; regionName: String := nil); override;
    begin
      inherited &Set(CreateKeyWithRegion(key, regionName), value, policy)
    end;

    method GetCacheItem(key: String; regionName: String := nil): CacheItem; override;
    begin
      var temporary: CacheItem := inherited GetCacheItem(CreateKeyWithRegion(key, regionName));
      exit new CacheItem(key, temporary.Value, regionName)
    end;

    method Get(key: String; regionName: String := nil): Object; override;
    begin
      exit inherited Get(CreateKeyWithRegion(key, regionName))
    end;

    property DefaultCacheCapabilities: DefaultCacheCapabilities read (inherited DefaultCacheCapabilities or System.Runtime.Caching.DefaultCacheCapabilities.CacheRegions); override;

  private

    method CreateKeyWithRegion(key: String; region: String): String;
    begin
      exit 'region:' + (iif(region = nil, 'null_region', region)) + ';key=' + key
    end;
  end;

end.
