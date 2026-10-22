export const shorthands = undefined;


export const up = (pgm) => {
    pgm.sql(`
        ALTER TABLE posts
        DROP COLUMN lat,
        DROP COLUMN lng;
    `);
};


export const down = (pgm) => {
    pgm.sql(`
        ALTER TABLE posts
        ADD COLUMN lat numeric,
        ADD COLUMN lng numeric;
    `);
};
