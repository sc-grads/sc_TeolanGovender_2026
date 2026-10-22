
const express = require('express');
const pg = require('pg');

const pool = new pg.Pool({
  host: 'localhost',
  port: 5432,
  database: 'socialnetwork',
  user: 'postgres',
  password: 'Password123!',
});

const app = express();

app.use(express.urlencoded({ extended: true }));

app.get('/posts', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM posts;');

    res.send(`
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Lng</th>
            <th>Lat</th>
          </tr>
        </thead>
        <tbody>
          ${rows
            .map(
              (row) => `
                <tr>
                  <td>${row.id}</td>
                  <td>${row.loc.x}</td>
                  <td>${row.loc.y}</td>
                </tr>
              `
            )
            .join('')}
        </tbody>
      </table>

      <form method="POST" action="/posts">
        <h3>Create Post</h3>
        <div>
          <label>Lng</label>
          <input name="lng" type="number" step="any" required />
        </div>
        <div>
          <label>Lat</label>
          <input name="lat" type="number" step="any" required />
        </div>
        <button type="submit">Create</button>
      </form>
    `);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error retrieving posts');
  }
});

app.post('/posts', async (req, res) => {
  const { lng, lat } = req.body;

  try {
    await pool.query(
      'INSERT INTO posts (loc) VALUES ($1);',
      [`(${lng}, ${lat})`]
    );

    res.redirect('/posts');
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Error creating post');
  }
});

app.listen(3005, () => {
  console.log('Listening on port 3005');
});