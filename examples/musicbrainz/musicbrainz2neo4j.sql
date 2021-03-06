
-- Change TABs to spaces in "name" column for "track" and "work" tables
-- somehow these TABs can make batch-import CSV parsing choked
UPDATE track SET name=translate(name, E'\t', ' ') WHERE name LIKE E'%\t%';
UPDATE work SET name=translate(name, E'\t', ' ') WHERE name LIKE E'%\t%';


-- Create the mapping table
-- between (entity, pk) tuples and incrementing node IDs


DROP TABLE IF EXISTS entity_mapping;

CREATE TEMPORARY TABLE entity_mapping AS
(
    
    SELECT
        kind AS entity,
        pk,
        row_number() OVER (ORDER BY kind, pk) as node_id
    FROM
    (
        (SELECT
          'area' as kind,
          area.id AS "pk"
        FROM
          area
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'area_alias' as kind,
          area_alias.id AS "pk"
        FROM
          area_alias
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'area_type' as kind,
          area_type.id AS "pk"
        FROM
          area_type
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'place' as kind,
          place.id AS "pk"
        FROM
          place
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'place_alias' as kind,
          place_alias.id AS "pk"
        FROM
          place_alias
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'artist' as kind,
          artist.id AS "pk"
        FROM
          artist
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'artist_alias' as kind,
          artist_alias.id AS "pk"
        FROM
          artist_alias
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'artist_type' as kind,
          artist_type.id AS "pk"
        FROM
          artist_type
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'artist_credit' as kind,
          artist_credit.id AS "pk"
        FROM
          artist_credit
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'gender' as kind,
          gender.id AS "pk"
        FROM
          gender
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'label' as kind,
          label.id AS "pk"
        FROM
          label
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'label_type' as kind,
          label_type.id AS "pk"
        FROM
          label_type
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'url' as kind,
          url.id AS "pk"
        FROM
          url
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'release_group' as kind,
          release_group.id AS "pk"
        FROM
          release_group
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'release_group_primary_type' as kind,
          release_group_primary_type.id AS "pk"
        FROM
          release_group_primary_type
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'release' as kind,
          release.id AS "pk"
        FROM
          release
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'release_packaging' as kind,
          release_packaging.id AS "pk"
        FROM
          release_packaging
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'release_status' as kind,
          release_status.id AS "pk"
        FROM
          release_status
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'recording' as kind,
          recording.id AS "pk"
        FROM
          recording
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'track' as kind,
          track.id AS "pk"
        FROM
          track
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'medium' as kind,
          medium.id AS "pk"
        FROM
          medium
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'medium_format' as kind,
          medium_format.id AS "pk"
        FROM
          medium_format
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'work' as kind,
          work.id AS "pk"
        FROM
          work
        ORDER BY pk)
        
        UNION
        
        (SELECT
          'work_type' as kind,
          work_type.id AS "pk"
        FROM
          work_type
        ORDER BY pk)
    )
    AS entity_union 
    
);

-- create index to speedup lookups
CREATE INDEX ON entity_mapping (entity, pk);

ANALYZE entity_mapping;



COPY(
   
   SELECT
      wrapped.disambiguation AS disambiguation,
      wrapped.position AS position,
      translate(
          array_to_string(
              ARRAY[
                  initcap(wrapped.kind::text),
                  initcap(wrapped.type::text),
                  initcap(wrapped.format::text),
                  initcap(wrapped.gender::text),
                  initcap(wrapped.status::text),
                  initcap(wrapped.packaging::text)],
              ','),
          ' _"/-', '') AS "l:label",
      wrapped.name AS "name:string:mb_fulltext",
      wrapped.length AS length,
      wrapped.mbid AS "mbid:string:mb_exact"
   FROM (
      
      (SELECT
        'area' as kind,
        area__type__area_type.name AS "type",
        0 AS "position",
        area.name AS "name",
        area.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        area.gid AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        area
        LEFT JOIN area_type AS area__type__area_type ON area__type__area_type.id = area.type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'area_alias' as kind,
        area_alias__type__area_alias_type.name AS "type",
        0 AS "position",
        area_alias.name AS "name",
        area_alias.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        area_alias.locale AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        area_alias
        LEFT JOIN area_alias_type AS area_alias__type__area_alias_type ON area_alias__type__area_alias_type.id = area_alias.type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'area_type' as kind,
        NULL AS "type",
        0 AS "position",
        area_type.name AS "name",
        area_type.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        area_type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'place' as kind,
        place__type__place_type.name AS "type",
        0 AS "position",
        place.name AS "name",
        place.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        place.coordinates[1] AS "longitude",
        place.coordinates[0] AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        place.gid AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        place
        LEFT JOIN place_type AS place__type__place_type ON place__type__place_type.id = place.type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'place_alias' as kind,
        place_alias__type__place_alias_type.name AS "type",
        0 AS "position",
        place_alias.name AS "name",
        place_alias.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        place_alias.locale AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        place_alias
        LEFT JOIN place_alias_type AS place_alias__type__place_alias_type ON place_alias__type__place_alias_type.id = place_alias.type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'artist' as kind,
        artist__type__artist_type.name AS "type",
        0 AS "position",
        artist.name AS "name",
        artist.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        artist.gid AS "mbid",
        artist__gender__gender.name AS "gender",
        artist.comment AS "disambiguation",
        NULL AS "packaging"
      FROM
        artist
        LEFT JOIN artist_type AS artist__type__artist_type ON artist__type__artist_type.id = artist.type
        LEFT JOIN gender AS artist__gender__gender ON artist__gender__gender.id = artist.gender
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'artist_alias' as kind,
        artist_alias__type__artist_alias_type.name AS "type",
        0 AS "position",
        artist_alias.name AS "name",
        artist_alias.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        artist_alias
        LEFT JOIN artist_alias_type AS artist_alias__type__artist_alias_type ON artist_alias__type__artist_alias_type.id = artist_alias.type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'artist_type' as kind,
        NULL AS "type",
        0 AS "position",
        artist_type.name AS "name",
        artist_type.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        artist_type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'artist_credit' as kind,
        NULL AS "type",
        0 AS "position",
        artist_credit.name AS "name",
        artist_credit.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        artist_credit
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'gender' as kind,
        NULL AS "type",
        0 AS "position",
        gender.name AS "name",
        gender.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        gender
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'label' as kind,
        label__type__label_type.name AS "type",
        0 AS "position",
        label.name AS "name",
        label.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        label.label_code AS "code",
        label.gid AS "mbid",
        NULL AS "gender",
        label.comment AS "disambiguation",
        NULL AS "packaging"
      FROM
        label
        LEFT JOIN label_type AS label__type__label_type ON label__type__label_type.id = label.type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'label_type' as kind,
        NULL AS "type",
        0 AS "position",
        label_type.name AS "name",
        label_type.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        label_type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'url' as kind,
        NULL AS "type",
        0 AS "position",
        url.url AS "name",
        url.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        url.gid AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        url
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'release_group' as kind,
        release_group__type__release_group_primary_type.name AS "type",
        0 AS "position",
        release_group.name AS "name",
        release_group.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        release_group.gid AS "mbid",
        NULL AS "gender",
        release_group.comment AS "disambiguation",
        NULL AS "packaging"
      FROM
        release_group
        LEFT JOIN release_group_primary_type AS release_group__type__release_group_primary_type ON release_group__type__release_group_primary_type.id = release_group.type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'release_group_primary_type' as kind,
        NULL AS "type",
        0 AS "position",
        release_group_primary_type.name AS "name",
        release_group_primary_type.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        release_group_primary_type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'release' as kind,
        NULL AS "type",
        0 AS "position",
        release.name AS "name",
        release.id AS "pk",
        release__status__release_status.name AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        release.gid AS "mbid",
        NULL AS "gender",
        release.comment AS "disambiguation",
        release__packaging__release_packaging.name AS "packaging"
      FROM
        release
        LEFT JOIN release_status AS release__status__release_status ON release__status__release_status.id = release.status
        LEFT JOIN release_packaging AS release__packaging__release_packaging ON release__packaging__release_packaging.id = release.packaging
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'release_packaging' as kind,
        NULL AS "type",
        0 AS "position",
        release_packaging.name AS "name",
        release_packaging.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        release_packaging
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'release_status' as kind,
        NULL AS "type",
        0 AS "position",
        release_status.name AS "name",
        release_status.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        release_status
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'recording' as kind,
        NULL AS "type",
        0 AS "position",
        recording.name AS "name",
        recording.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        recording.gid AS "mbid",
        NULL AS "gender",
        recording.comment AS "disambiguation",
        NULL AS "packaging"
      FROM
        recording
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'track' as kind,
        NULL AS "type",
        track.position AS "position",
        track.name AS "name",
        track.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        track.length AS "length",
        NULL AS "locale",
        0 AS "code",
        track.gid AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        track
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'medium' as kind,
        NULL AS "type",
        0 AS "position",
        medium.name AS "name",
        medium.id AS "pk",
        NULL AS "status",
        medium__format__medium_format.name AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        medium
        LEFT JOIN medium_format AS medium__format__medium_format ON medium__format__medium_format.id = medium.format
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'medium_format' as kind,
        NULL AS "type",
        0 AS "position",
        medium_format.name AS "name",
        medium_format.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        medium_format
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'work' as kind,
        work__type__work_type.name AS "type",
        0 AS "position",
        work.name AS "name",
        work.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        work.gid AS "mbid",
        NULL AS "gender",
        work.comment AS "disambiguation",
        NULL AS "packaging"
      FROM
        work
        LEFT JOIN work_type AS work__type__work_type ON work__type__work_type.id = work.type
      ORDER BY pk)
      
      UNION
      
      (SELECT
        'work_type' as kind,
        NULL AS "type",
        0 AS "position",
        work_type.name AS "name",
        work_type.id AS "pk",
        NULL AS "status",
        NULL AS "format",
        0 AS "longitude",
        0 AS "latitude",
        0 AS "length",
        NULL AS "locale",
        0 AS "code",
        NULL AS "mbid",
        NULL AS "gender",
        NULL AS "disambiguation",
        NULL AS "packaging"
      FROM
        work_type
      ORDER BY pk)
      ORDER BY kind, pk
      
   )
   AS wrapped
           
)
TO '/tmp/musicbrainz__nodes__full.csv' CSV HEADER
DELIMITER E'\t'
ENCODING 'UTF8';


COPY(
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'HAS_ALIAS' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     area_alias
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = area_alias.area
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = area_alias.id
               AND
               end_entity.entity = 'area_alias'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'HAS_ALIAS' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     place_alias
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = place_alias.place
               AND
               start_entity.entity = 'place'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = place_alias.id
               AND
               end_entity.entity = 'place_alias'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'FROM_AREA' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     artist
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = artist.id
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = artist.area
               AND
               end_entity.entity = 'area'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'BEGAN_IN_AREA' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     artist
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = artist.id
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = artist.begin_area
               AND
               end_entity.entity = 'area'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'ENDED_IN_AREA' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     artist
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = artist.id
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = artist.end_area
               AND
               end_entity.entity = 'area'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'HAS_ALIAS' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     artist_alias
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = artist_alias.artist
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = artist_alias.id
               AND
               end_entity.entity = 'artist_alias'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'CREDITED_AS' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     artist_credit_name.join_phrase AS "join",
     0 AS "year",
     artist_credit_name.position AS "position"
   FROM
     artist_credit_name
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = artist_credit_name.artist
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = artist_credit_name.artist_credit
               AND
               end_entity.entity = 'artist_credit'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'FROM_AREA' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     label
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = label.id
               AND
               start_entity.entity = 'label'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = label.area
               AND
               end_entity.entity = 'area'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'CREDITED_ON' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     release_group
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = release_group.artist_credit
               AND
               start_entity.entity = 'artist_credit'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = release_group.id
               AND
               end_entity.entity = 'release_group'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'CREDITED_ON' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     release
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = release.artist_credit
               AND
               start_entity.entity = 'artist_credit'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = release.id
               AND
               end_entity.entity = 'release'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'PART_OF' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     release
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = release.id
               AND
               start_entity.entity = 'release'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = release.release_group
               AND
               end_entity.entity = 'release_group'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'RELEASED_IN' AS rel_type,
     release_country.date_day AS "day",
     release_country.date_month AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     release_country.date_year AS "year",
     0 AS "position"
   FROM
     release_country
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = release_country.release
               AND
               start_entity.entity = 'release'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = release_country.country
               AND
               end_entity.entity = 'area'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'RELEASED_ON' AS rel_type,
     0 AS "day",
     0 AS "month",
     release_label.catalog_number AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     release_label
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = release_label.release
               AND
               start_entity.entity = 'release'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = release_label.label
               AND
               end_entity.entity = 'label'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'CREDITED_ON' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     recording
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = recording.artist_credit
               AND
               start_entity.entity = 'artist_credit'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = recording.id
               AND
               end_entity.entity = 'recording'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'IS_RECORDING' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     track
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = track.id
               AND
               start_entity.entity = 'track'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = track.recording
               AND
               end_entity.entity = 'recording'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'APPEARS_ON' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     track
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = track.id
               AND
               start_entity.entity = 'track'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = track.medium
               AND
               end_entity.entity = 'medium'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'CREDITED_ON' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     track
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = track.artist_credit
               AND
               start_entity.entity = 'artist_credit'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = track.id
               AND
               end_entity.entity = 'track'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'RELEASED_ON_MEDIUM' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     medium
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = medium.release
               AND
               start_entity.entity = 'release'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = medium.id
               AND
               end_entity.entity = 'medium'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     'PARENT_FORMAT' AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     medium_format
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = medium_format.id
               AND
               start_entity.entity = 'medium_format'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = medium_format.parent
               AND
               end_entity.entity = 'medium_format'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_area_area__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_area_area
     JOIN link AS l_area_area__link__link ON l_area_area__link__link.id = l_area_area.link
     JOIN link_type AS l_area_area__link__link__link_type__link_type ON l_area_area__link__link__link_type__link_type.id = l_area_area__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_area_area.entity0
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_area_area.entity1
               AND
               end_entity.entity = 'area'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_area_artist__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_area_artist
     JOIN link AS l_area_artist__link__link ON l_area_artist__link__link.id = l_area_artist.link
     JOIN link_type AS l_area_artist__link__link__link_type__link_type ON l_area_artist__link__link__link_type__link_type.id = l_area_artist__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_area_artist.entity0
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_area_artist.entity1
               AND
               end_entity.entity = 'artist'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_area_label__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_area_label
     JOIN link AS l_area_label__link__link ON l_area_label__link__link.id = l_area_label.link
     JOIN link_type AS l_area_label__link__link__link_type__link_type ON l_area_label__link__link__link_type__link_type.id = l_area_label__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_area_label.entity0
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_area_label.entity1
               AND
               end_entity.entity = 'label'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_area_work__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_area_work
     JOIN link AS l_area_work__link__link ON l_area_work__link__link.id = l_area_work.link
     JOIN link_type AS l_area_work__link__link__link_type__link_type ON l_area_work__link__link__link_type__link_type.id = l_area_work__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_area_work.entity0
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_area_work.entity1
               AND
               end_entity.entity = 'work'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_area_url__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_area_url
     JOIN link AS l_area_url__link__link ON l_area_url__link__link.id = l_area_url.link
     JOIN link_type AS l_area_url__link__link__link_type__link_type ON l_area_url__link__link__link_type__link_type.id = l_area_url__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_area_url.entity0
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_area_url.entity1
               AND
               end_entity.entity = 'url'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_area_recording__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_area_recording
     JOIN link AS l_area_recording__link__link ON l_area_recording__link__link.id = l_area_recording.link
     JOIN link_type AS l_area_recording__link__link__link_type__link_type ON l_area_recording__link__link__link_type__link_type.id = l_area_recording__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_area_recording.entity0
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_area_recording.entity1
               AND
               end_entity.entity = 'recording'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_area_release__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_area_release
     JOIN link AS l_area_release__link__link ON l_area_release__link__link.id = l_area_release.link
     JOIN link_type AS l_area_release__link__link__link_type__link_type ON l_area_release__link__link__link_type__link_type.id = l_area_release__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_area_release.entity0
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_area_release.entity1
               AND
               end_entity.entity = 'release'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_area_release_group__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_area_release_group
     JOIN link AS l_area_release_group__link__link ON l_area_release_group__link__link.id = l_area_release_group.link
     JOIN link_type AS l_area_release_group__link__link__link_type__link_type ON l_area_release_group__link__link__link_type__link_type.id = l_area_release_group__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_area_release_group.entity0
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_area_release_group.entity1
               AND
               end_entity.entity = 'release_group'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_area_place__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_area_place
     JOIN link AS l_area_place__link__link ON l_area_place__link__link.id = l_area_place.link
     JOIN link_type AS l_area_place__link__link__link_type__link_type ON l_area_place__link__link__link_type__link_type.id = l_area_place__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_area_place.entity0
               AND
               start_entity.entity = 'area'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_area_place.entity1
               AND
               end_entity.entity = 'place'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_artist_artist__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_artist_artist
     JOIN link AS l_artist_artist__link__link ON l_artist_artist__link__link.id = l_artist_artist.link
     JOIN link_type AS l_artist_artist__link__link__link_type__link_type ON l_artist_artist__link__link__link_type__link_type.id = l_artist_artist__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_artist_artist.entity0
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_artist_artist.entity1
               AND
               end_entity.entity = 'artist'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_artist_label__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_artist_label
     JOIN link AS l_artist_label__link__link ON l_artist_label__link__link.id = l_artist_label.link
     JOIN link_type AS l_artist_label__link__link__link_type__link_type ON l_artist_label__link__link__link_type__link_type.id = l_artist_label__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_artist_label.entity0
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_artist_label.entity1
               AND
               end_entity.entity = 'label'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_artist_recording__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_artist_recording
     JOIN link AS l_artist_recording__link__link ON l_artist_recording__link__link.id = l_artist_recording.link
     JOIN link_type AS l_artist_recording__link__link__link_type__link_type ON l_artist_recording__link__link__link_type__link_type.id = l_artist_recording__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_artist_recording.entity0
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_artist_recording.entity1
               AND
               end_entity.entity = 'recording'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_artist_release__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_artist_release
     JOIN link AS l_artist_release__link__link ON l_artist_release__link__link.id = l_artist_release.link
     JOIN link_type AS l_artist_release__link__link__link_type__link_type ON l_artist_release__link__link__link_type__link_type.id = l_artist_release__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_artist_release.entity0
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_artist_release.entity1
               AND
               end_entity.entity = 'release'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_artist_release_group__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_artist_release_group
     JOIN link AS l_artist_release_group__link__link ON l_artist_release_group__link__link.id = l_artist_release_group.link
     JOIN link_type AS l_artist_release_group__link__link__link_type__link_type ON l_artist_release_group__link__link__link_type__link_type.id = l_artist_release_group__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_artist_release_group.entity0
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_artist_release_group.entity1
               AND
               end_entity.entity = 'release_group'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_artist_url__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_artist_url
     JOIN link AS l_artist_url__link__link ON l_artist_url__link__link.id = l_artist_url.link
     JOIN link_type AS l_artist_url__link__link__link_type__link_type ON l_artist_url__link__link__link_type__link_type.id = l_artist_url__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_artist_url.entity0
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_artist_url.entity1
               AND
               end_entity.entity = 'url'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_artist_work__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_artist_work
     JOIN link AS l_artist_work__link__link ON l_artist_work__link__link.id = l_artist_work.link
     JOIN link_type AS l_artist_work__link__link__link_type__link_type ON l_artist_work__link__link__link_type__link_type.id = l_artist_work__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_artist_work.entity0
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_artist_work.entity1
               AND
               end_entity.entity = 'work'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_artist_place__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_artist_place
     JOIN link AS l_artist_place__link__link ON l_artist_place__link__link.id = l_artist_place.link
     JOIN link_type AS l_artist_place__link__link__link_type__link_type ON l_artist_place__link__link__link_type__link_type.id = l_artist_place__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_artist_place.entity0
               AND
               start_entity.entity = 'artist'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_artist_place.entity1
               AND
               end_entity.entity = 'place'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_label_label__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_label_label
     JOIN link AS l_label_label__link__link ON l_label_label__link__link.id = l_label_label.link
     JOIN link_type AS l_label_label__link__link__link_type__link_type ON l_label_label__link__link__link_type__link_type.id = l_label_label__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_label_label.entity0
               AND
               start_entity.entity = 'label'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_label_label.entity1
               AND
               end_entity.entity = 'label'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_label_recording__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_label_recording
     JOIN link AS l_label_recording__link__link ON l_label_recording__link__link.id = l_label_recording.link
     JOIN link_type AS l_label_recording__link__link__link_type__link_type ON l_label_recording__link__link__link_type__link_type.id = l_label_recording__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_label_recording.entity0
               AND
               start_entity.entity = 'label'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_label_recording.entity1
               AND
               end_entity.entity = 'recording'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_label_release__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_label_release
     JOIN link AS l_label_release__link__link ON l_label_release__link__link.id = l_label_release.link
     JOIN link_type AS l_label_release__link__link__link_type__link_type ON l_label_release__link__link__link_type__link_type.id = l_label_release__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_label_release.entity0
               AND
               start_entity.entity = 'label'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_label_release.entity1
               AND
               end_entity.entity = 'release'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_label_release_group__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_label_release_group
     JOIN link AS l_label_release_group__link__link ON l_label_release_group__link__link.id = l_label_release_group.link
     JOIN link_type AS l_label_release_group__link__link__link_type__link_type ON l_label_release_group__link__link__link_type__link_type.id = l_label_release_group__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_label_release_group.entity0
               AND
               start_entity.entity = 'label'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_label_release_group.entity1
               AND
               end_entity.entity = 'release_group'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_label_url__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_label_url
     JOIN link AS l_label_url__link__link ON l_label_url__link__link.id = l_label_url.link
     JOIN link_type AS l_label_url__link__link__link_type__link_type ON l_label_url__link__link__link_type__link_type.id = l_label_url__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_label_url.entity0
               AND
               start_entity.entity = 'label'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_label_url.entity1
               AND
               end_entity.entity = 'url'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_label_work__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_label_work
     JOIN link AS l_label_work__link__link ON l_label_work__link__link.id = l_label_work.link
     JOIN link_type AS l_label_work__link__link__link_type__link_type ON l_label_work__link__link__link_type__link_type.id = l_label_work__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_label_work.entity0
               AND
               start_entity.entity = 'label'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_label_work.entity1
               AND
               end_entity.entity = 'work'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_label_place__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_label_place
     JOIN link AS l_label_place__link__link ON l_label_place__link__link.id = l_label_place.link
     JOIN link_type AS l_label_place__link__link__link_type__link_type ON l_label_place__link__link__link_type__link_type.id = l_label_place__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_label_place.entity0
               AND
               start_entity.entity = 'label'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_label_place.entity1
               AND
               end_entity.entity = 'place'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_place_place__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_place_place
     JOIN link AS l_place_place__link__link ON l_place_place__link__link.id = l_place_place.link
     JOIN link_type AS l_place_place__link__link__link_type__link_type ON l_place_place__link__link__link_type__link_type.id = l_place_place__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_place_place.entity0
               AND
               start_entity.entity = 'place'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_place_place.entity1
               AND
               end_entity.entity = 'place'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_place_recording__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_place_recording
     JOIN link AS l_place_recording__link__link ON l_place_recording__link__link.id = l_place_recording.link
     JOIN link_type AS l_place_recording__link__link__link_type__link_type ON l_place_recording__link__link__link_type__link_type.id = l_place_recording__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_place_recording.entity0
               AND
               start_entity.entity = 'place'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_place_recording.entity1
               AND
               end_entity.entity = 'recording'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_place_release__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_place_release
     JOIN link AS l_place_release__link__link ON l_place_release__link__link.id = l_place_release.link
     JOIN link_type AS l_place_release__link__link__link_type__link_type ON l_place_release__link__link__link_type__link_type.id = l_place_release__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_place_release.entity0
               AND
               start_entity.entity = 'place'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_place_release.entity1
               AND
               end_entity.entity = 'release'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_place_release_group__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_place_release_group
     JOIN link AS l_place_release_group__link__link ON l_place_release_group__link__link.id = l_place_release_group.link
     JOIN link_type AS l_place_release_group__link__link__link_type__link_type ON l_place_release_group__link__link__link_type__link_type.id = l_place_release_group__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_place_release_group.entity0
               AND
               start_entity.entity = 'place'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_place_release_group.entity1
               AND
               end_entity.entity = 'release_group'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_place_url__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_place_url
     JOIN link AS l_place_url__link__link ON l_place_url__link__link.id = l_place_url.link
     JOIN link_type AS l_place_url__link__link__link_type__link_type ON l_place_url__link__link__link_type__link_type.id = l_place_url__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_place_url.entity0
               AND
               start_entity.entity = 'place'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_place_url.entity1
               AND
               end_entity.entity = 'url'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_place_work__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_place_work
     JOIN link AS l_place_work__link__link ON l_place_work__link__link.id = l_place_work.link
     JOIN link_type AS l_place_work__link__link__link_type__link_type ON l_place_work__link__link__link_type__link_type.id = l_place_work__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_place_work.entity0
               AND
               start_entity.entity = 'place'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_place_work.entity1
               AND
               end_entity.entity = 'work'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_recording_recording__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_recording_recording
     JOIN link AS l_recording_recording__link__link ON l_recording_recording__link__link.id = l_recording_recording.link
     JOIN link_type AS l_recording_recording__link__link__link_type__link_type ON l_recording_recording__link__link__link_type__link_type.id = l_recording_recording__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_recording_recording.entity0
               AND
               start_entity.entity = 'recording'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_recording_recording.entity1
               AND
               end_entity.entity = 'recording'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_recording_release__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_recording_release
     JOIN link AS l_recording_release__link__link ON l_recording_release__link__link.id = l_recording_release.link
     JOIN link_type AS l_recording_release__link__link__link_type__link_type ON l_recording_release__link__link__link_type__link_type.id = l_recording_release__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_recording_release.entity0
               AND
               start_entity.entity = 'recording'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_recording_release.entity1
               AND
               end_entity.entity = 'release'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_recording_release_group__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_recording_release_group
     JOIN link AS l_recording_release_group__link__link ON l_recording_release_group__link__link.id = l_recording_release_group.link
     JOIN link_type AS l_recording_release_group__link__link__link_type__link_type ON l_recording_release_group__link__link__link_type__link_type.id = l_recording_release_group__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_recording_release_group.entity0
               AND
               start_entity.entity = 'recording'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_recording_release_group.entity1
               AND
               end_entity.entity = 'release_group'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_recording_url__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_recording_url
     JOIN link AS l_recording_url__link__link ON l_recording_url__link__link.id = l_recording_url.link
     JOIN link_type AS l_recording_url__link__link__link_type__link_type ON l_recording_url__link__link__link_type__link_type.id = l_recording_url__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_recording_url.entity0
               AND
               start_entity.entity = 'recording'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_recording_url.entity1
               AND
               end_entity.entity = 'url'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_recording_work__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_recording_work
     JOIN link AS l_recording_work__link__link ON l_recording_work__link__link.id = l_recording_work.link
     JOIN link_type AS l_recording_work__link__link__link_type__link_type ON l_recording_work__link__link__link_type__link_type.id = l_recording_work__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_recording_work.entity0
               AND
               start_entity.entity = 'recording'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_recording_work.entity1
               AND
               end_entity.entity = 'work'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_release_release__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_release_release
     JOIN link AS l_release_release__link__link ON l_release_release__link__link.id = l_release_release.link
     JOIN link_type AS l_release_release__link__link__link_type__link_type ON l_release_release__link__link__link_type__link_type.id = l_release_release__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_release_release.entity0
               AND
               start_entity.entity = 'release'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_release_release.entity1
               AND
               end_entity.entity = 'release'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_release_release_group__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_release_release_group
     JOIN link AS l_release_release_group__link__link ON l_release_release_group__link__link.id = l_release_release_group.link
     JOIN link_type AS l_release_release_group__link__link__link_type__link_type ON l_release_release_group__link__link__link_type__link_type.id = l_release_release_group__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_release_release_group.entity0
               AND
               start_entity.entity = 'release'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_release_release_group.entity1
               AND
               end_entity.entity = 'release_group'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_release_url__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_release_url
     JOIN link AS l_release_url__link__link ON l_release_url__link__link.id = l_release_url.link
     JOIN link_type AS l_release_url__link__link__link_type__link_type ON l_release_url__link__link__link_type__link_type.id = l_release_url__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_release_url.entity0
               AND
               start_entity.entity = 'release'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_release_url.entity1
               AND
               end_entity.entity = 'url'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_release_work__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_release_work
     JOIN link AS l_release_work__link__link ON l_release_work__link__link.id = l_release_work.link
     JOIN link_type AS l_release_work__link__link__link_type__link_type ON l_release_work__link__link__link_type__link_type.id = l_release_work__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_release_work.entity0
               AND
               start_entity.entity = 'release'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_release_work.entity1
               AND
               end_entity.entity = 'work'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_release_group_release_group__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_release_group_release_group
     JOIN link AS l_release_group_release_group__link__link ON l_release_group_release_group__link__link.id = l_release_group_release_group.link
     JOIN link_type AS l_release_group_release_group__link__link__link_type__link_type ON l_release_group_release_group__link__link__link_type__link_type.id = l_release_group_release_group__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_release_group_release_group.entity0
               AND
               start_entity.entity = 'release_group'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_release_group_release_group.entity1
               AND
               end_entity.entity = 'release_group'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_release_group_url__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_release_group_url
     JOIN link AS l_release_group_url__link__link ON l_release_group_url__link__link.id = l_release_group_url.link
     JOIN link_type AS l_release_group_url__link__link__link_type__link_type ON l_release_group_url__link__link__link_type__link_type.id = l_release_group_url__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_release_group_url.entity0
               AND
               start_entity.entity = 'release_group'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_release_group_url.entity1
               AND
               end_entity.entity = 'url'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_release_group_work__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_release_group_work
     JOIN link AS l_release_group_work__link__link ON l_release_group_work__link__link.id = l_release_group_work.link
     JOIN link_type AS l_release_group_work__link__link__link_type__link_type ON l_release_group_work__link__link__link_type__link_type.id = l_release_group_work__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_release_group_work.entity0
               AND
               start_entity.entity = 'release_group'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_release_group_work.entity1
               AND
               end_entity.entity = 'work'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_url_url__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_url_url
     JOIN link AS l_url_url__link__link ON l_url_url__link__link.id = l_url_url.link
     JOIN link_type AS l_url_url__link__link__link_type__link_type ON l_url_url__link__link__link_type__link_type.id = l_url_url__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_url_url.entity0
               AND
               start_entity.entity = 'url'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_url_url.entity1
               AND
               end_entity.entity = 'url'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_url_work__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_url_work
     JOIN link AS l_url_work__link__link ON l_url_work__link__link.id = l_url_work.link
     JOIN link_type AS l_url_work__link__link__link_type__link_type ON l_url_work__link__link__link_type__link_type.id = l_url_work__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_url_work.entity0
               AND
               start_entity.entity = 'url'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_url_work.entity1
               AND
               end_entity.entity = 'work'
           ))
   
   UNION
   
   (SELECT
     start_entity.node_id AS start,
     end_entity.node_id AS end,
     translate(upper(l_work_work__link__link__link_type__link_type.name), ' ', '_') AS rel_type,
     0 AS "day",
     0 AS "month",
     NULL AS "catalog_number",
     NULL AS "join",
     0 AS "year",
     0 AS "position"
   FROM
     l_work_work
     JOIN link AS l_work_work__link__link ON l_work_work__link__link.id = l_work_work.link
     JOIN link_type AS l_work_work__link__link__link_type__link_type ON l_work_work__link__link__link_type__link_type.id = l_work_work__link__link.link_type
     
       JOIN entity_mapping start_entity
           ON (
               start_entity.pk = l_work_work.entity0
               AND
               start_entity.entity = 'work'
           )
     
       JOIN entity_mapping end_entity
           ON (
               end_entity.pk = l_work_work.entity1
               AND
               end_entity.entity = 'work'
           ))
)
TO '/tmp/musicbrainz__rels__full.csv' CSV HEADER
DELIMITER E'\t'
ENCODING 'UTF8';

