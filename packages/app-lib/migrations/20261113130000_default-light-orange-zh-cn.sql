-- The build default moves to the light theme, the orange accent and Chinese.
-- A local document records only the keys that differ from the default, so a row
-- still holding the previous default cannot be told apart from one a user chose
-- that happened to equal it: bringing the old default forward moves everyone who
-- never wrote an override and leaves anyone who did.
UPDATE settings
SET theme = 'light',
    accent_color = 'orange',
    locale = 'zh-CN'
WHERE id = 0
  AND theme = 'dark'
  AND accent_color = 'pink'
  AND locale = '';
