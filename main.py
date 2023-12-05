from typing import List, Dict
import json
import os
import sys


def list_files(files_path: str) -> List:

    files_list = [file for file in os.listdir(files_path) if os.path.isfile(f"{files_path}/{file}")]

    return files_list


def read_json_file(files_path: str, file_name: str) -> str:
    f = open(f"{files_path}/{file_name}")
    data = json.load(f)
    query_str = data[0].get("queryStr")
    f.close()

    return query_str


def find_queries_with_specific_word(files_path: str, word: str) -> Dict:
    output_dict = {}

    files_list = list_files(files_path=files_path)

    for file_name in files_list:
        query_str = read_json_file(files_path=files_path, file_name=file_name)
        if query_str is not None:
            if word in query_str:
                output_dict[file_name] = query_str

    return output_dict


def dump_dict_data(
    data_dict : Dict,
    word: str
) -> None:
    
    word_path = f"utils/words/{word}"

    if not os.path.exists(word_path):
        os.makedirs(word_path)

    json.dump( data_dict, open( f"{word_path}/queries.json", 'w' ) )

    for file_name in data_dict:
        new_file_name = file_name.replace('.json', '')
        f = open(f"{word_path}/{new_file_name}.sql", "w")
        f.write(data_dict.get(file_name))
        f.close()


def main() -> None:
    word = sys.argv[1]
    data_dict = find_queries_with_specific_word(
        files_path="utils/queries_json", word=word
    )
    dump_dict_data(data_dict=data_dict, word=word)


if __name__ == "__main__":
    main()
