// json-db.w

bring fs;

pub class JsonDb {
  filename: str;

  new(filename: str, defaultValue: Json) {
    this.filename = filename;

    if !fs.exists(filename) {
      fs.writeFile(filename, "");
      fs.writeJson(filename, defaultValue);
    }
  }

  pub inflight data(): MutJson {
    return fs.readJson(this.filename);
  }

  pub inflight update(fn: inflight (MutJson): void) {
    let data = fs.readJson(this.filename);

    fn(data);

    fs.writeJson(this.filename, data);
  }
}
