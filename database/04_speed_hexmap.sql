-- DROP FUNCTION public.speed_hexmap(int4, int4, int4, json);

CREATE OR REPLACE
FUNCTION public.speed_hexmap(z integer,
x integer,
y integer,
query_params JSON)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
DECLARE
  mvt bytea;

threshold_zoom integer := 17;
-- set your threshold zoom level here
tile_margin NUMERIC;
-- set your threshold zoom level here
hex_area NUMERIC;
-- variable to store hexagon area
vehicle_types vehicle_type_enum[];
-- array to store vehicle types from query parameters

margin_tile_geom geometry;

tile_geom geometry;

time_bin_size_ms integer := 1000 * 10;
-- time bin SIZE IS 10 s * 1000 FOR ms
BEGIN
	

IF query_params->'vehicle_types' IS NOT NULL THEN
	    vehicle_types := ARRAY(
SELECT
	json_array_elements_text(query_params->'vehicle_types')::vehicle_type_enum);
ELSE
	    vehicle_types := '{}';
-- assign an empty array if 'vehicle_types' is not in query_params
END IF;
-- check if vehicle_types array is empty and set it to null if it is
	IF vehicle_types = '{}' THEN
	    vehicle_types := NULL;
END IF;

IF z < threshold_zoom THEN
		hex_area := 43.870;
-- example area value for resolution 13
tile_margin := 8;
ELSE
		hex_area := 6.267;
-- example area value for resolution level 14
tile_margin := 6;
END IF;

tile_geom := st_transform(st_tileenvelope(z,
x,
y),
4326);

margin_tile_geom := st_transform(st_envelope(st_buffer(st_tileenvelope(z,
x,
y),
tile_margin)),
4326);

WITH time_bounds AS (
SELECT
	min(timestamp) AS time_min,
	max(timestamp) AS time_max
FROM
	points
),
time_bins AS (
SELECT
	generate_series(time_bounds.time_min::integer,
	time_bounds.time_max::integer,
	time_bin_size_ms::integer) AS time_bin
FROM
	time_bounds
)
-- generating the mvt with pre-existing hexagonal grid
  SELECT
	INTO
	mvt st_asmvt(tile,
	'speed_hexmap',
	4096,
	'geom')
FROM
	(
	SELECT
		st_asmvtgeom(
        avg_points.geom,
		-- existing hexagonal grid geometry
		tile_geom,
		4096,
		64,
		TRUE) AS geom,
		hex_id,
		hex_area AS area,
		avg_speeds[1] AS speed_1,
		avg_speeds[2] AS speed_2,
		avg_speeds[3] AS speed_3,
		avg_speeds[4] AS speed_4,
		avg_speeds[5] AS speed_5,
		avg_speeds[6] AS speed_6,
		avg_speeds[7] AS speed_7,
		avg_speeds[8] AS speed_8,
		avg_speeds[9] AS speed_9,
		avg_speeds[10] AS speed_10,
		avg_speeds[11] AS speed_11,
		avg_speeds[12] AS speed_12,
		avg_speeds[13] AS speed_13,
		avg_speeds[14] AS speed_14,
		avg_speeds[15] AS speed_15,
		avg_speeds[16] AS speed_16,
		avg_speeds[17] AS speed_17,
		avg_speeds[18] AS speed_18,
		avg_speeds[19] AS speed_19,
		avg_speeds[20] AS speed_20,
		avg_speeds[21] AS speed_21,
		avg_speeds[22] AS speed_22,
		avg_speeds[23] AS speed_23,
		avg_speeds[24] AS speed_24,
		avg_speeds[25] AS speed_25,
		avg_speeds[26] AS speed_26,
		avg_speeds[27] AS speed_27,
		avg_speeds[28] AS speed_28,
		avg_speeds[29] AS speed_29,
				avg_speeds[30] AS speed_30,
		avg_speeds[31] AS speed_31,
		avg_speeds[32] AS speed_32,
		avg_speeds[33] AS speed_33,
		avg_speeds[34] AS speed_34,
		avg_speeds[35] AS speed_35,
		avg_speeds[36] AS speed_36,
		avg_speeds[37] AS speed_37,
		avg_speeds[38] AS speed_38,
		avg_speeds[39] AS speed_39,
		avg_speeds[40] AS speed_40,
		avg_speeds[41] AS speed_41,
		avg_speeds[42] AS speed_42,
		avg_speeds[43] AS speed_43,
		avg_speeds[44] AS speed_44,
		avg_speeds[45] AS speed_45,
		avg_speeds[46] AS speed_46,
		avg_speeds[47] AS speed_47,
		avg_speeds[48] AS speed_48,
		avg_speeds[49] AS speed_49,
		avg_speeds[50] AS speed_50,
		avg_speeds[51] AS speed_51,
		avg_speeds[52] AS speed_52,
		avg_speeds[53] AS speed_53,
		avg_speeds[54] AS speed_54,
		avg_speeds[55] AS speed_55,
		avg_speeds[56] AS speed_56,
		avg_speeds[57] AS speed_57,
		avg_speeds[58] AS speed_58,
		avg_speeds[59] AS speed_59,
		avg_speeds[60] AS speed_60,
		avg_speeds[61] AS speed_61,
		avg_speeds[62] AS speed_62,
		avg_speeds[63] AS speed_63,
		avg_speeds[64] AS speed_64,
		avg_speeds[65] AS speed_65,
		avg_speeds[66] AS speed_66,
		avg_speeds[67] AS speed_67,
		avg_speeds[68] AS speed_68,
		avg_speeds[69] AS speed_69,
		avg_speeds[70] AS speed_70,
		avg_speeds[71] AS speed_71,
		avg_speeds[72] AS speed_72,
		avg_speeds[73] AS speed_73,
		avg_speeds[74] AS speed_74,
		avg_speeds[75] AS speed_75,
		avg_speeds[76] AS speed_76,
		avg_speeds[77] AS speed_77,
		avg_speeds[78] AS speed_78,
		avg_speeds[79] AS speed_79,
		avg_speeds[80] AS speed_80,
		avg_speeds[81] AS speed_81,
		avg_speeds[82] AS speed_82,
		avg_speeds[83] AS speed_83,
		avg_speeds[84] AS speed_84,
		avg_speeds[85] AS speed_85,
		avg_speeds[86] AS speed_86,
		avg_speeds[87] AS speed_87,
		avg_speeds[88] AS speed_88,
		avg_speeds[89] AS speed_89,
		avg_speeds[90] AS speed_90,
		avg_speeds[91] AS speed_91,
		avg_speeds[92] AS speed_92,
		avg_speeds[93] AS speed_93,
		avg_speeds[94] AS speed_94,
		avg_speeds[95] AS speed_95,
		avg_speeds[96] AS speed_96,
		avg_speeds[97] AS speed_97,
		avg_speeds[98] AS speed_98,
		avg_speeds[99] AS speed_99,
		avg_speeds[100] AS speed_100,
		avg_speeds[101] AS speed_101,
		avg_speeds[102] AS speed_102,
		avg_speeds[103] AS speed_103,
		avg_speeds[104] AS speed_104,
		avg_speeds[105] AS speed_105,
		avg_speeds[106] AS speed_106,
		avg_speeds[107] AS speed_107,
		avg_speeds[108] AS speed_108,
		avg_speeds[109] AS speed_109,
		avg_speeds[110] AS speed_110,
		avg_speeds[111] AS speed_111,
		avg_speeds[112] AS speed_112,
		avg_speeds[113] AS speed_113,
		avg_speeds[114] AS speed_114,
		avg_speeds[115] AS speed_115,
		avg_speeds[116] AS speed_116,
		avg_speeds[117] AS speed_117,
		avg_speeds[118] AS speed_118,
		avg_speeds[119] AS speed_119,
		avg_speeds[120] AS speed_120,
		avg_speeds[121] AS speed_121,
		avg_speeds[122] AS speed_122,
		avg_speeds[123] AS speed_123,
		avg_speeds[124] AS speed_124,
		avg_speeds[125] AS speed_125,
		avg_speeds[126] AS speed_126,
		avg_speeds[127] AS speed_127,
		avg_speeds[128] AS speed_128,
		avg_speeds[129] AS speed_129,
		avg_speeds[130] AS speed_130,
		avg_speeds[131] AS speed_131,
		avg_speeds[132] AS speed_132,
		avg_speeds[133] AS speed_133,
		avg_speeds[134] AS speed_134,
		avg_speeds[135] AS speed_135,
		avg_speeds[136] AS speed_136,
		avg_speeds[137] AS speed_137,
		avg_speeds[138] AS speed_138,
		avg_speeds[139] AS speed_139,
		avg_speeds[140] AS speed_140,
		avg_speeds[141] AS speed_141,
		avg_speeds[142] AS speed_142,
		avg_speeds[143] AS speed_143,
		avg_speeds[144] AS speed_144,
		avg_speeds[145] AS speed_145,
		avg_speeds[146] AS speed_146,
		avg_speeds[147] AS speed_147,
		avg_speeds[148] AS speed_148,
		avg_speeds[149] AS speed_149,
		avg_speeds[150] AS speed_150,
		avg_speeds[151] AS speed_151,
		avg_speeds[152] AS speed_152,
		avg_speeds[153] AS speed_153,
		avg_speeds[154] AS speed_154,
		avg_speeds[155] AS speed_155,
		avg_speeds[156] AS speed_156,
		avg_speeds[157] AS speed_157,
		avg_speeds[158] AS speed_158,
		avg_speeds[159] AS speed_159,
		avg_speeds[160] AS speed_160,
		avg_speeds[161] AS speed_161,
		avg_speeds[162] AS speed_162,
		avg_speeds[163] AS speed_163,
		avg_speeds[164] AS speed_164,
		avg_speeds[165] AS speed_165,
		avg_speeds[166] AS speed_166,
		avg_speeds[167] AS speed_167,
		avg_speeds[168] AS speed_168,
		avg_speeds[169] AS speed_169,
		avg_speeds[170] AS speed_170,
		avg_speeds[171] AS speed_171,
		avg_speeds[172] AS speed_172,
		avg_speeds[173] AS speed_173,
		avg_speeds[174] AS speed_174,
		avg_speeds[175] AS speed_175,
		avg_speeds[176] AS speed_176,
		avg_speeds[177] AS speed_177,
		avg_speeds[178] AS speed_178,
		avg_speeds[179] AS speed_179,
		avg_speeds[180] AS speed_180,
		avg_freqs[1] AS freq_1,
		avg_freqs[2] AS freq_2,
		avg_freqs[3] AS freq_3,
		avg_freqs[4] AS freq_4,
		avg_freqs[5] AS freq_5,
		avg_freqs[6] AS freq_6,
		avg_freqs[7] AS freq_7,
		avg_freqs[8] AS freq_8,
		avg_freqs[9] AS freq_9,
		avg_freqs[10] AS freq_10,
		avg_freqs[11] AS freq_11,
		avg_freqs[12] AS freq_12,
		avg_freqs[13] AS freq_13,
		avg_freqs[14] AS freq_14,
		avg_freqs[15] AS freq_15,
		avg_freqs[16] AS freq_16,
		avg_freqs[17] AS freq_17,
		avg_freqs[18] AS freq_18,
		avg_freqs[19] AS freq_19,
		avg_freqs[20] AS freq_20,
		avg_freqs[21] AS freq_21,
		avg_freqs[22] AS freq_22,
		avg_freqs[23] AS freq_23,
		avg_freqs[24] AS freq_24,
		avg_freqs[25] AS freq_25,
		avg_freqs[26] AS freq_26,
		avg_freqs[27] AS freq_27,
		avg_freqs[28] AS freq_28,
		avg_freqs[29] AS freq_29,
		avg_freqs[30] AS freq_30,
		avg_freqs[31] AS freq_31,
		avg_freqs[32] AS freq_32,
		avg_freqs[33] AS freq_33,
		avg_freqs[34] AS freq_34,
		avg_freqs[35] AS freq_35,
		avg_freqs[36] AS freq_36,
		avg_freqs[37] AS freq_37,
		avg_freqs[38] AS freq_38,
		avg_freqs[39] AS freq_39,
		avg_freqs[40] AS freq_40,
		avg_freqs[41] AS freq_41,
		avg_freqs[42] AS freq_42,
		avg_freqs[43] AS freq_43,
		avg_freqs[44] AS freq_44,
		avg_freqs[45] AS freq_45,
		avg_freqs[46] AS freq_46,
		avg_freqs[47] AS freq_47,
		avg_freqs[48] AS freq_48,
		avg_freqs[49] AS freq_49,
		avg_freqs[50] AS freq_50,
		avg_freqs[51] AS freq_51,
		avg_freqs[52] AS freq_52,
		avg_freqs[53] AS freq_53,
		avg_freqs[54] AS freq_54,
		avg_freqs[55] AS freq_55,
		avg_freqs[56] AS freq_56,
		avg_freqs[57] AS freq_57,
		avg_freqs[58] AS freq_58,
		avg_freqs[59] AS freq_59,
		avg_freqs[60] AS freq_60,
		avg_freqs[61] AS freq_61,
		avg_freqs[62] AS freq_62,
		avg_freqs[63] AS freq_63,
		avg_freqs[64] AS freq_64,
		avg_freqs[65] AS freq_65,
		avg_freqs[66] AS freq_66,
		avg_freqs[67] AS freq_67,
		avg_freqs[68] AS freq_68,
		avg_freqs[69] AS freq_69,
		avg_freqs[70] AS freq_70,
		avg_freqs[71] AS freq_71,
		avg_freqs[72] AS freq_72,
		avg_freqs[73] AS freq_73,
		avg_freqs[74] AS freq_74,
		avg_freqs[75] AS freq_75,
		avg_freqs[76] AS freq_76,
		avg_freqs[77] AS freq_77,
		avg_freqs[78] AS freq_78,
		avg_freqs[79] AS freq_79,
		avg_freqs[80] AS freq_80,
		avg_freqs[81] AS freq_81,
		avg_freqs[82] AS freq_82,
		avg_freqs[83] AS freq_83,
		avg_freqs[84] AS freq_84,
		avg_freqs[85] AS freq_85,
		avg_freqs[86] AS freq_86,
		avg_freqs[87] AS freq_87,
		avg_freqs[88] AS freq_88,
		avg_freqs[89] AS freq_89,
		avg_freqs[90] AS freq_90,
		avg_freqs[91] AS freq_91,
		avg_freqs[92] AS freq_92,
		avg_freqs[93] AS freq_93,
		avg_freqs[94] AS freq_94,
		avg_freqs[95] AS freq_95,
		avg_freqs[96] AS freq_96,
		avg_freqs[97] AS freq_97,
		avg_freqs[98] AS freq_98,
		avg_freqs[99] AS freq_99,
		avg_freqs[100] AS freq_100,
		avg_freqs[101] AS freq_101,
		avg_freqs[102] AS freq_102,
		avg_freqs[103] AS freq_103,
		avg_freqs[104] AS freq_104,
		avg_freqs[105] AS freq_105,
		avg_freqs[106] AS freq_106,
		avg_freqs[107] AS freq_107,
		avg_freqs[108] AS freq_108,
		avg_freqs[109] AS freq_109,
		avg_freqs[110] AS freq_110,
		avg_freqs[111] AS freq_111,
		avg_freqs[112] AS freq_112,
		avg_freqs[113] AS freq_113,
		avg_freqs[114] AS freq_114,
		avg_freqs[115] AS freq_115,
		avg_freqs[116] AS freq_116,
		avg_freqs[117] AS freq_117,
		avg_freqs[118] AS freq_118,
		avg_freqs[119] AS freq_119,
		avg_freqs[120] AS freq_120,
		avg_freqs[121] AS freq_121,
		avg_freqs[122] AS freq_122,
		avg_freqs[123] AS freq_123,
		avg_freqs[124] AS freq_124,
		avg_freqs[125] AS freq_125,
		avg_freqs[126] AS freq_126,
		avg_freqs[127] AS freq_127,
		avg_freqs[128] AS freq_128,
		avg_freqs[129] AS freq_129,
		avg_freqs[130] AS freq_130,
		avg_freqs[131] AS freq_131,
		avg_freqs[132] AS freq_132,
		avg_freqs[133] AS freq_133,
		avg_freqs[134] AS freq_134,
		avg_freqs[135] AS freq_135,
		avg_freqs[136] AS freq_136,
		avg_freqs[137] AS freq_137,
		avg_freqs[138] AS freq_138,
		avg_freqs[139] AS freq_139,
		avg_freqs[140] AS freq_140,
		avg_freqs[141] AS freq_141,
		avg_freqs[142] AS freq_142,
		avg_freqs[143] AS freq_143,
		avg_freqs[144] AS freq_144,
		avg_freqs[145] AS freq_145,
		avg_freqs[146] AS freq_146,
		avg_freqs[147] AS freq_147,
		avg_freqs[148] AS freq_148,
		avg_freqs[149] AS freq_149,
		avg_freqs[150] AS freq_150,
		avg_freqs[151] AS freq_151,
		avg_freqs[152] AS freq_152,
		avg_freqs[153] AS freq_153,
		avg_freqs[154] AS freq_154,
		avg_freqs[155] AS freq_155,
		avg_freqs[156] AS freq_156,
		avg_freqs[157] AS freq_157,
		avg_freqs[158] AS freq_158,
		avg_freqs[159] AS freq_159,
		avg_freqs[160] AS freq_160,
		avg_freqs[161] AS freq_161,
		avg_freqs[162] AS freq_162,
		avg_freqs[163] AS freq_163,
		avg_freqs[164] AS freq_164,
		avg_freqs[165] AS freq_165,
		avg_freqs[166] AS freq_166,
		avg_freqs[167] AS freq_167,
		avg_freqs[168] AS freq_168,
		avg_freqs[169] AS freq_169,
		avg_freqs[170] AS freq_170,
		avg_freqs[171] AS freq_171,
		avg_freqs[172] AS freq_172,
		avg_freqs[173] AS freq_173,
		avg_freqs[174] AS freq_174,
		avg_freqs[175] AS freq_175,
		avg_freqs[176] AS freq_176,
		avg_freqs[177] AS freq_177,
		avg_freqs[178] AS freq_178,
		avg_freqs[179] AS freq_179,
		avg_freqs[180] AS freq_180
	FROM
		(
		SELECT
			hex_id,
			geom,
			array_agg(avg_speed) AS avg_speeds,
			array_agg(freq) AS avg_freqs
		FROM
			(
			SELECT
				hexs.hex_id AS hex_id,
				hexs.geom AS geom,
				hexs.time_bin AS time_bin,
				COALESCE (avg(p.speed)::SMALLINT,
				NULL) AS avg_speed,
				CASE
					WHEN count(p.*) = 0 THEN NULL
					ELSE count(p.*)::SMALLINT
				END AS freq
			FROM
				(
				SELECT
					hex_id,
					time_bin,
					geom
				FROM
					hexagons
				CROSS JOIN time_bins
				WHERE
					geom && margin_tile_geom
					AND (CASE
						WHEN z < threshold_zoom THEN res = 13
						ELSE res = 14
					END)
				) AS hexs
			LEFT JOIN 
			    points p ON
				(CASE 
					WHEN z < threshold_zoom THEN hexs.hex_id = p.hex_id_13
					ELSE hexs.hex_id = p.hex_id_14
				END)
				AND p.timestamp BETWEEN time_bin AND time_bin + time_bin_size_ms
			WHERE
				vehicle_types IS NULL
				OR p.vehicle_type IS NULL
				OR p.vehicle_type = ANY(vehicle_types)
			GROUP BY
				hexs.hex_id,
				hexs.geom,
				hexs.time_bin

		) AS subquery
		GROUP BY
			hex_id,
			geom
    ) AS avg_points
  ) AS tile
WHERE
	geom IS NOT NULL;

RETURN mvt;
END
$function$
;
