import os

class PathHandler:

    def join_folder(self, current_dir, new_dir=''):
        '''Only join parent_dir and child_dir'''
        output_dir = os.path.join(current_dir, new_dir)
        return output_dir

    def create_folder(self, current_dir, new_dir=''):
        '''join to new dir path and create folder'''
        output_dir = self.join_folder(current_dir, new_dir)
        if not os.path.exists(output_dir):
            os.mkdir(output_dir)
        return output_dir

    def join_file_path(self, current_dir, filename=''):
        '''join dir with filename'''
        output_file_path = os.path.join(current_dir, filename)
        return output_file_path