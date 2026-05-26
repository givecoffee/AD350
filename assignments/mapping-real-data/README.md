## Week 2 Devlog - Mapping Real Data 

Video Demo - https://www.youtube.com/watch?v=4uc9YTbF57Y 

I was excited to work on this project of developing a community garden management system, as I love to garden and I have been wanting to create a hybrid app for tracking both indoor and outdoor plants. It's always good to try and solve problems you already have or can understand. For this project, we will be going back to Supabase and creating a table called 'plants'. I was given data points and have to determine the best PostgreSQL type for each and explain my reasoning for choosing it for those use cases. This also gives me an opportunity to start thinking about scale. Personally, I own a VPS as a cost effective solution for hosting apps/websites. I will be creating the schema for the garden app and then hosting the Docker container on the server. I want the actual final version of my personal app, which is in a similar category, to have a mirrored database that is stored on the user's device so that it can be used offline. 

I generated fake user data using Mockaroo.com to help with the mock interviews feel more real, as you are trying to solve a real problem of large and messy datasets. Setting up your logic for data types early on is really important. I wanted to again get in the practice of keeping Row Level Security set to ON, and I think it is turned off by default. Either way, I made sure it was toggled and then created the plants table. First, I had to choose my data points and a suitable PostgreSQL type. 

| Data Point    | Description                                                                   | PostgreSQL Type    |
| ------------- | ----------------------------------------------------------------------------- | ------------------ |
| Plant ID      | A unique identifier that generates automatically for every new plant.         | SERIAL PRIMARY KEY |
| Common Name   | The name of the plant (e.g., "Tomato"). Max 100 characters.                   | varchar(100)       |
| Description   | A long-form paragraph about the plant's history and care.                     | text               |
| Is Edible?    | A simple yes/no check.                                                        | boolean            |
| Price         | The cost of a seed packet (e.g., $3.50). Must be exact.                       | numeric(10,2)      |
| Date Planted  | Only the date the seed was put in the ground.                                 | date               |
| Growth Tags   | A list of descriptors (e.g., "Organic", "Heirloom", "Sun-loving").            | text[] (array)     |
| Metadata      | Extra info from an external API in nested format (like weather requirements). | jsonb              |
| Internal UUID | A unique string for internal tracking that isn't a simple number.             | uuid               |

Justifications: 

For PRICE, I wanted to use numeric instead of a floating integer because numeric can store exact decima values, which is critical when working with currencies. As for IS EDIBLE(?), I used boolean because the field only needs a true or false (at least for the most part). We can explore the complexities later with that using metadata, but this way is efficient and prevents invalid values. I also want to touch on the JSONB being used instead of JSON for metadata real quick and that it is excellent for searching inside your data (being queryable) and fast! It also supports indexing, which is going to be an important upgrade and only works well with JSONB. I also learned that it stores data in a binary format which is parsed and optimized, resulting in faster reads (but slower writes) and highly efficient querying. Normalization of data also helps keep everything cleaner, removes the whitespace and removes/sorts keys so that you don't run into weird bugs involving formatting later. JSON would be great for scenarios where you want to preserve the formatting, if you want to keep duplicate keys, etc. If I want to query and index nested data, however, I need to filter through metadata so I will lean on JSONB.

Initial SQL table creation:

```
CREATE TABLE plants (
    plant_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_edible BOOLEAN DEFAULT FALSE,
    price NUMERIC(10,2),
    date_planted DATE,
    growth_tags VARCHAR[] DEFAULT '{}',
    metadata JSONB,
    internal_uuid UUID UNIQUE NOT NULL
);
```

I am going to use a seed script to drop data right into Supabase with varied data (tags + JSON metadata) which will put to test the structures we put into place.

```
insert into public.plants 
(common_name, description, is_edible, price, date_planted, growth_tags, metadata)
values

-- Tomato
(
  'Tomato',
  'A warm-season crop known for its juicy red fruit. Requires full sun and consistent watering. Popular in home gardens and versatile in cooking.',
  true,
  3.50,
  '2026-04-15',
  array['Organic', 'Heirloom', 'Sun-loving'],
  '{
    "sunlight": "full",
    "water": "moderate",
    "days_to_harvest": 75,
    "soil": "well-drained"
  }'
),

-- Basil
(
  'Basil',
  'A fragrant herb commonly used in Italian cuisine. Thrives in warm weather and benefits from regular harvesting.',
  true,
  2.25,
  '2026-05-01',
  array['Herb', 'Container-friendly', 'Fast-growing'],
  '{
    "sunlight": "full",
    "water": "moderate",
    "days_to_harvest": 30,
    "soil": "rich"
  }'
),

-- Carrot
(
  'Carrot',
  'A root vegetable that grows best in loose, sandy soil. Known for its sweet flavor and high vitamin A content.',
  true,
  1.99,
  '2026-03-20',
  array['Root', 'Cool-season', 'Direct-sow'],
  '{
    "sunlight": "full",
    "water": "low",
    "days_to_harvest": 70,
    "soil": "sandy"
  }'
),

-- Lavender
(
  'Lavender',
  'A drought-tolerant flowering plant prized for its fragrance and calming properties. Attracts pollinators.',
  false,
  4.75,
  '2026-04-10',
  array['Perennial', 'Pollinator-friendly', 'Drought-tolerant'],
  '{
    "sunlight": "full",
    "water": "low",
    "days_to_bloom": 90,
    "soil": "dry"
  }'
),

-- Spinach
(
  'Spinach',
  'A leafy green vegetable that grows quickly in cool weather. Ideal for salads and cooking.',
  true,
  2.10,
  '2026-03-05',
  array['Leafy', 'Cool-season', 'Fast-growing'],
  '{
    "sunlight": "partial",
    "water": "moderate",
    "days_to_harvest": 40,
    "soil": "moist"
  }'
),

-- Strawberry
(
  'Strawberry',
  'A sweet fruit-bearing plant that produces runners. Requires good drainage and plenty of sunlight.',
  true,
  5.00,
  '2026-04-01',
  array['Fruit', 'Perennial', 'Runner-producing'],
  '{
    "sunlight": "full",
    "water": "moderate",
    "days_to_harvest": 60,
    "soil": "loamy"
  }'
),

-- Mint
(
  'Mint',
  'A vigorous herb known for its refreshing flavor. Spreads rapidly and is best grown in containers.',
  true,
  1.75,
  '2026-05-10',
  array['Herb', 'Invasive', 'Container-friendly'],
  '{
    "sunlight": "partial",
    "water": "high",
    "days_to_harvest": 25,
    "soil": "moist"
  }'
),

-- Bell Pepper
(
  'Bell Pepper',
  'A colorful vegetable that thrives in warm temperatures. Produces sweet, crunchy fruits in various colors.',
  true,
  3.80,
  '2026-04-20',
  array['Warm-season', 'Vegetable', 'Sun-loving'],
  '{
    "sunlight": "full",
    "water": "moderate",
    "days_to_harvest": 80,
    "soil": "fertile"
  }'
);
```

But I ran into an issue where the constraints (although working correctly) prevented a column from defaulting to something other than NULL. For UUID, it cannot be null but there is nothing defaulted for the input. 

Here is an alteration that adds a default UUID that is randomized: 

```
alter table public.plants
alter column internal_uuid
set default gen_random_uuid();
```

After running that alteration, the seed script now works and returns with "Success. No rows returned." After inspecting the table, it has Plant IDs 2-9, from tomato to bell pepper. They come with set price values, descriptions, edible indicators, and the other randomized data. The JSONB loaded metadata successfully about the soil, water, sunlight conditions as well. 
